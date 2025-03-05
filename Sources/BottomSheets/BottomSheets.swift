import SwiftUI

@available(iOS, introduced: 16.4, deprecated: 16.4, message: "Since iOS 16 provides a native bottom sheet, using this flag is pointless.")
/*
 NativeBottomSheetViewModifier - это обертка над стандартным presentationDetents.
 Он нужен для того, чтобы преобразовать backported BPresentationDetent в нативный PresentationDetent.
 
 NativeBottomSheetViewModifier is a wrapper around the standard presentationDetents.
 It is used to convert the backported BPresentationDetent into a native PresentationDetent.
 */
internal struct NativeBottomSheetViewModifier<BottomSheetContent: View>: ViewModifier {
    
    // Local state for disableSwipeToDismiss
    @State private var disableSwipeToDismiss = false
    
    @Binding var isPresented: Bool

    let detents: Set<BPresentationDetent>
    let interaction: BPresentationBackgroundInteraction
    
    @Binding var selection: BPresentationDetent
    
    let bottomSheetContent: BottomSheetContent
    
    /*
     Храним сопоставление между BPresentationDetent и PresentationDetent,
     чтобы сделать custom binding,
     т к в .modal нам нужно в selection получить именно BPresentationDetent.
     
     We store the mapping between BPresentationDetent and PresentationDetent
     to create a custom binding,
     since in .modal we need to have BPresentationDetent in the selection.
     */
    private let detentMapping: [BPresentationDetent: PresentationDetent]
    
    @State private var backgroundPreference: Color = .white
    @State private var backgroundCornerRadius: CGFloat = 12.0
    
    init(
        isPresented: Binding<Bool>,
        detents: Set<BPresentationDetent>,
        interaction: BPresentationBackgroundInteraction = .automatic,
        selection: Binding<BPresentationDetent>,
        @ViewBuilder bottomSheetContent: @escaping () -> BottomSheetContent
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self.interaction = interaction
        self._selection = selection
        self.bottomSheetContent = bottomSheetContent()
        
        var mapping: [BPresentationDetent: PresentationDetent] = [:]
        for detent in detents {
            mapping[detent] = detent.toPresentationDetent
        }
        self.detentMapping = mapping
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                SheetContentWrapper(
                    disableSwipeToDismiss: $disableSwipeToDismiss,
                    isPresented: $isPresented,
                    bottomSheetContent: bottomSheetContent
                        .onPreferenceChange(PresentationBackgroundPreferenceKey.self) { preference in
                            self.backgroundPreference = preference
                        }
                        .onPreferenceChange(PresentationCornerRadiusPreferenceKey.self) { preference in
                            self.backgroundCornerRadius = preference ?? 12.0
                        }
                )
                .presentationDetents(
                    Set(detentMapping.values),
                    selection: Binding<PresentationDetent>(
                        get: {
                            detentMapping[$selection.wrappedValue] ?? .large
                        },
                        set: { newValue in
                            if let customDetent = detentMapping.first(where: { $0.value == newValue })?.key {
                                $selection.wrappedValue = customDetent
                            }
                        }
                    )
                )
                .presentationBackgroundInteraction(interaction.toSUI) // <== из-за этого модификатора поддержка с 16.4 (Because of this modifier, support starts from 16.4)
                .ignoresSafeArea()
                .presentationBackground { backgroundPreference } // <== из-за этого модификатора поддержка с 16.4 (Because of this modifier, support starts from 16.4)
                .presentationCornerRadius(backgroundCornerRadius) // <== из-за этого модификатора поддержка с 16.4 (Because of this modifier, support starts from 16.4)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(disableSwipeToDismiss)
            }
    }
}

/*
 SheetContentWrapper - обертка над контентом шторки, в которой добавляем drag индикатор и кнопка закрытия.
 
 SheetContentWrapper is a wrapper around the sheet content that adds a drag indicator and a close button.
 */
internal struct SheetContentWrapper<BottomSheetContent: View>: View {
    
    @Binding var disableSwipeToDismiss: Bool
    @Binding var isPresented: Bool
    let bottomSheetContent: BottomSheetContent
    
    @State private var dragIndicatorVisibility: BVisibility = .visible
    
    var body: some View {
        // Трюк, чтобы поджать все к верху:
        // A trick to push everything to the top:
        ScrollView([], showsIndicators: false) {
            VStack(spacing: 0) {
                if dragIndicatorVisibility == .visible {
                    pinView
                        .padding(.top, 8)
                        .layoutPriority(.infinity)
                }
                Spacer().frame(height: 28)
                
                bottomSheetContent
                    .onPreferenceChange(DisableSwipeToDismissPreferenceKey.self) { value in
                        disableSwipeToDismiss = value
                    }
                    .onPreferenceChange(DragIndicatorPreferenceKey.self) { value in
                        dragIndicatorVisibility = value
                    }
                    
            }
            .padding(.horizontal, 20.0)
            .padding(.bottom, 40.0)
        }
    }
    
    /*
     Drag индикатор для шторки
     Drag indicator
     */
    private var pinView: some View {
        Capsule()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 32, height: 4)
            .contentShape(Rectangle())
    }
}

@available(iOS, deprecated: 16.4, message: "Since iOS 16 provides a native bottom sheet, using this BottomSheetViewModifier is pointless.")
/*
 BottomSheetViewModifier - это и есть бэкпорт нативной реализации presentationDetents, доступной с iOS 16.
 
 BottomSheetViewModifier is a backport of the native presentationDetents implementation available since iOS 16.
 */
internal struct BottomSheetViewModifier<BottomSheetContent: View>: ViewModifier {

    // Локальное состояние для хранения значения disableSwipeToDismiss
    // Local state var for disableSwipeToDismiss
    @State private var disableSwipeToDismiss = false
    
    @Binding var isPresented: Bool
    let bottomSheetContent: BottomSheetContent
    
    @State private var offsetY: CGFloat = 0 // для управления свайпом (for swiping control)
    
    /*
     Настройки шторки
     
     Bottom sheet settings
     */
    
    // Максимальное допустимое растяжение выше максимального детента
    // The maximum allowable offset above the highest detent
    @State private var overdragLimit: CGFloat = 50.0
    
    // радиус закругления углов у шторки
    // The corner radius of the sheet
    @State private var backgroundCornerRadius: CGFloat = 12.0
    
    // цвет подложки при появлении шторки
    // Overlay color for main content
    @State private var overlayColor = Color.black.opacity(0.5)
    
    // тень
    // shadow
    @State private var shadowData: PresentationShadowData? = nil
    
    // цвет background шторки
    // background color
    @State private var backgroundColor: Color = .white
    
    // возможность пользователя взаимодействовать с контентом (по-умолч включено)
    //
    // User interaction with the content (Enabled by default)
    //
    @State private var allowsHitTesting: Bool = true

    // Жест для отслеживания перемещения
    // A gesture to tracking offset
    @GestureState private var translation: CGFloat = 0
    
    // Связанный параметр для управления текущим детентом
    // Parameter to control the current detent.
    @Binding private var currentDetent: BPresentationDetent
    
    // Множество доступных детентов
    // Available detents
    let detents: Set<BPresentationDetent>
    
    // Взаимодействие с фоном
    // Background interaction
    let interaction: BPresentationBackgroundInteraction
    
    init(
        isPresented: Binding<Bool>,
        detents: Set<BPresentationDetent>,
        interaction: BPresentationBackgroundInteraction = .automatic,
        currentDetent: Binding<BPresentationDetent>,
        @ViewBuilder bottomSheetContent: @escaping () -> BottomSheetContent
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self.interaction = interaction
        self._currentDetent = currentDetent
        self.bottomSheetContent = bottomSheetContent()
    }
    
    public func body(content: Content) -> some View {
        Group {
            switch interaction.type {
                
            case .enabledUpThrough(let maxDetent):
                ZStack(alignment: .bottom) {
                    content
                        .allowsHitTesting(allowsHitTesting)
                        .zIndex(1.0)
                    
                    if isPresented {
                        sheetContentView(maxDetent)
                            .zIndex(3.0)
                    }
                }
                
            case .enabled:
                ZStack(alignment: .bottom) {
                    content
                        .zIndex(1.0)
                    
                    if isPresented {
                        sheetContentView()
                            .zIndex(3.0)
                    }
                }
                
                
            default: // including disabled
                ZStack {
                    content
                        .zIndex(1.0)
                    
                    contentOverlayColor
                        .opacity(isPresented ? 1 : 0)
                        .zIndex(2.0)
                }
                .fullScreenCover(isPresented: $isPresented) {
                    sheetContentView()
                        .onChange(of: isPresented) { isPresented in
                            UIView.setAnimationsEnabled(false)
                        }
                        .clearModalBackground {
                            if isPresented && disableSwipeToDismiss == false {
                                isPresented = false
                            }
                        }
                        .onAppear {
                            if !UIView.areAnimationsEnabled {
                                UIView.setAnimationsEnabled(true)
                            }
                        }
                        .onDisappear {
                            if !UIView.areAnimationsEnabled {
                                UIView.setAnimationsEnabled(true)
                            }
                        }
                        .ignoresSafeArea()
                }
                
            }
        }
        .animation(.bottomSheet, value: isPresented)
    }
    
    private var contentOverlayColor: some View {
        overlayColor
            .ignoresSafeArea()
            .onTapGesture {
                // Закрываем модалку, если нажали за пределами ее контента
                // Dismiss the modal if user tapped outside its content.
                if isPresented {
                    isPresented = false
                }
            }
    }
    
    @ViewBuilder
    private func sheetContentView(_ maxDetent: BPresentationDetent? = nil) -> some View {
        GeometryReader { geometry in
            let containerHeight = geometry.size.height
            
            // Сортируем детенты по высоте
            // Sorting detents by height
            let sortedDetents = detents.sortedByHeight(in: containerHeight)
            let detentHeights = sortedDetents.map { $0.height(in: containerHeight) }
            
            // Минимальный и максимальный детенты
            // Minimum and maximum detents
            let minDetentHeight = detentHeights.first ?? 0
            let maxDetentHeight = detentHeights.last ?? containerHeight * 0.99
            
            // Минимальный детент для закрытия шторки
            // Minimum detent for closing the sheet
            let minDetentForClosingSheet = disableSwipeToDismiss ? minDetentHeight : 0
            
            // Текущая высота шторки с учетом жеста и эффекта оттягивания
            // Current sheet height considering gestures and pull-back effect
            let currentHeight: CGFloat = {
                let currentDetentHeight = currentDetent.height(in: containerHeight)
                let newHeight = currentDetentHeight - translation
                if newHeight > maxDetentHeight {
                    // Применяем эффект оттягивания
                    // Apply pull-back effect
                    let extraHeight = newHeight - maxDetentHeight
                    let resistance = extraHeight / (1 + abs(extraHeight) / overdragLimit)
                    return maxDetentHeight + resistance
                } else if newHeight < minDetentForClosingSheet {
                    // Применяем эффект оттягивания при опускании ниже минимального детента
                    // Apply pull-back effect when dropping below the minimum detent
                    let extraHeight = newHeight - minDetentHeight
                    let resistance = extraHeight / (1 + abs(extraHeight) / overdragLimit)
                    return minDetentForClosingSheet + resistance
                } else {
                    return newHeight
                }
            }()

            SheetContentWrapper(
                disableSwipeToDismiss: $disableSwipeToDismiss,
                isPresented: $isPresented,
                bottomSheetContent: bottomSheetContent
                    .onPreferenceChange(PresentationOverDragLimitPreferenceKey.self) { value in
                        overdragLimit = value
                    }
                    .onPreferenceChange(PresentationCornerRadiusPreferenceKey.self) { preference in
                        self.backgroundCornerRadius = preference ?? 12.0
                    }
                    .onPreferenceChange(PresentationContentOverlayPreferenceKey.self) { value in
                        withAnimation(.none) {
                            overlayColor = value
                        }
                    }
                    .onPreferenceChange(PresentationShadowDataPreferenceKey.self) { value in
                        shadowData = value
                    }
                    .onPreferenceChange(PresentationBackgroundPreferenceKey.self) { preference in
                        self.backgroundColor = preference
                    }
            )
            .background(backgroundColor)
            .frame(width: geometry.size.width, height: currentHeight, alignment: .top)
            .cornerRadiusLib(backgroundCornerRadius, corners: [.topLeft, .topRight])
            .shadow(color: shadowData?.color ?? .clear, radius: shadowData?.radius ?? 0, x: shadowData?.x ?? 0, y: shadowData?.y ?? 0)
            // Ограничиваем размер шторки по высоте экрана
            // Setting the limit the sheet size to the screen height
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            // Добавляем жест перетаскивания
            // Add drag gesture
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let currentDetentHeight = currentDetent.height(in: containerHeight)
                        let newHeight = currentDetentHeight - value.translation.height
                        let velocity = value.velocity.height
                        
                        if disableSwipeToDismiss == false && (newHeight < minDetentHeight * 0.7 || velocity > 1000) {
                            // Закрываем шторку, если опущена ниже 70% минимального детента или скорость свайпа вниз высокая
                            // Close the sheet if dragged below 70% of the minimum detent or the swipe-down velocity is high
                            self.isPresented = false
                        } else {
                            let newDetent = closestDetent(to: newHeight, in: containerHeight)
                            self.currentDetent = newDetent
                            if let maxDetent = maxDetent{
                                allowsHitTesting = currentHeight < maxDetent.height(in: containerHeight)
                            }
                        }
                    }
            )
            .onDisappear {
                offsetY = 0
                isPresented = false
                allowsHitTesting = true
            }
        }
        .animation(.bottomSheet, value: translation)
        .animation(.bottomSheet, value: currentDetent)
        .transition(
            .asymmetric(
                insertion: .move(edge: .bottom),
                removal: .move(edge: .bottom)
            )
        )
    }
    
    // Функция для определения ближайшего детента
    // Function to determine the nearest detent
    private func closestDetent(to value: CGFloat, in containerHeight: CGFloat) -> BPresentationDetent {
        let sortedDetents = detents.sortedByHeight(in: containerHeight)
        return sortedDetents.min(by: {
            abs($0.height(in: containerHeight) - value) < abs($1.height(in: containerHeight) - value)
        }) ?? currentDetent
    }
}

@available(iOS, deprecated: 16.4, message: "Since iOS 16 provides a native bottom sheet, using this BottomSheetView is pointless.")
/*
 BottomSheetView - основное view, где как раз и выбираем, какую шторку (native или custom) показывать в зависимости от iOS
 
 BottomSheetView is the main view where we choose which sheet (native or custom) to show depending on the iOS version.
 */
internal struct BottomSheetView<Content: View, BottomSheetContent: View>: View {
    @Environment(\.disableNativeBottomSheet) private var disableNativeBottomSheet: Bool
    
    @Binding var isPresented: Bool
    let detents: Set<BPresentationDetent>
    @Binding var selection: BPresentationDetent
    let interaction: BPresentationBackgroundInteraction
    let content: Content
    @ViewBuilder let bottomSheetContent: () -> BottomSheetContent
    
    var body: some View {
        if #available(iOS 16.4, *), disableNativeBottomSheet == false {
            // Используем встроенную реализацию на iOS 16 и выше
            // Native sheet
            content.modifier(
                NativeBottomSheetViewModifier(
                    isPresented: $isPresented,
                    detents: detents,
                    interaction: interaction,
                    selection: $selection,
                    bottomSheetContent: bottomSheetContent
                )
            )
        } else {
            // Backported:
            content.modifier(
                BottomSheetViewModifier(
                    isPresented: $isPresented,
                    detents: detents,
                    currentDetent: $selection,
                    bottomSheetContent: bottomSheetContent
                )
            )
        }
    }
}

@available(iOS, deprecated: 16.4, message: "Since iOS 16 provides a native bottom sheet, using this BottomSheetViewCutted is pointless.")
/*
 BottomSheetViewCutted - сокращенная версия BottomSheetView, нужна для того, чтобы НЕ передавать selection - выбранный detent - наверх
 
 BottomSheetViewCutted used to avoid passing the selected detent upward
 */
internal struct BottomSheetViewCutted<Content: View, BottomSheetContent: View>: View {
    @Environment(\.disableNativeBottomSheet) private var disableNativeBottomSheet: Bool
    
    @Binding var isPresented: Bool
    let detents: Set<BPresentationDetent>
    let interaction: BPresentationBackgroundInteraction
    let content: Content
    @ViewBuilder let bottomSheetContent: () -> BottomSheetContent
    
    @State private var selection: BPresentationDetent = .medium
    
    var body: some View {
        if #available(iOS 16.4, *), disableNativeBottomSheet == false {
            // Используем встроенную реализацию на iOS 16 и выше
            // Native sheet:
            content.modifier(
                NativeBottomSheetViewModifier(
                    isPresented: $isPresented,
                    detents: detents,
                    interaction: interaction,
                    selection: $selection,
                    bottomSheetContent: bottomSheetContent
                )
            )
        }
        else {
            // Backported:
            content.modifier(
                BottomSheetViewModifier(
                    isPresented: $isPresented,
                    detents: detents,
                    interaction: interaction,
                    currentDetent: $selection,
                    bottomSheetContent: bottomSheetContent
                )
            )
        }
    }
}

public extension View {
    @ViewBuilder
    func bottomSheet<BottomSheetContent: View>(
        isPresented: Binding<Bool>,
        _ detents: Set<BPresentationDetent> = [.medium],
        selection: Binding<BPresentationDetent>? = nil,
        interaction: BPresentationBackgroundInteraction = .automatic,
        @ViewBuilder content: @escaping () -> BottomSheetContent
    ) -> some View {
        
        if let selection = selection {
            BottomSheetView(
                isPresented: isPresented,
                detents: detents,
                selection: selection,
                interaction: interaction,
                content: self,
                bottomSheetContent: content
            )
        } else {
            BottomSheetViewCutted(
                isPresented: isPresented,
                detents: detents,
                interaction: interaction,
                content: self,
                bottomSheetContent: content
            )
        }
    }
}
