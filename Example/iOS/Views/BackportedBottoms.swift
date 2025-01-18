import SwiftUI
import BottomSheets

struct BackportedBottoms: View {
    @State private var showWithDetents: Bool = false
    @State private var showWithoutDetents: Bool = false
    @State private var showDisableSwipeToDismiss: Bool = false
    @State private var showFullyCustomSheet: Bool = false
    @State private var showSheetWithBackgroundIteraction: Bool = false
    
    @State private var currentDetent: BPresentationDetent = .medium
    
    @State private var sheetContentHeight = CGFloat(0)
    
    // Since iOS 16 SwiftUI provides native bottom sheet
    @State private  var disableNativeBottomSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.5)
            ScrollView {
                VStack(spacing: 40.0) {
                    Text("Bottom sheets demo")
                        .font(.title)
                    
                    Text("current detent: \(currentDetent)")
                    
                    Toggle(isOn: $disableNativeBottomSheet) {
                        Text(disableNativeBottomSheet ? "Custom bottom sheets" : "Native bottom sheets (since ios 16)")
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 20.0) {
                        Button {
                            showWithDetents.toggle()
                        } label: {
                            Text("With detents")
                        }
                        
                        Button {
                            showWithoutDetents.toggle()
                        } label: {
                            Text("Without detent (one position)")
                        }
                        
                        Button {
                            showDisableSwipeToDismiss.toggle()
                        } label: {
                            Text("Disabled swiping down")
                        }
                        
                        Button {
                            showFullyCustomSheet.toggle()
                        } label: {
                            Text("Fully custom")
                        }
                        
                        Button {
                            showSheetWithBackgroundIteraction.toggle()
                        } label: {
                            Text("With different background iteraction")
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .padding(.top, 100)
        }
        // 1: Sheet with multiple detents.
        .bottomSheet(
            isPresented: $showWithDetents,
            [.height(300), .medium, .fraction(0.60), .fraction(0.90)],
            selection: $currentDetent
        ) {
            BottomContent() {
                showWithDetents.toggle()
            }
        }
        // 2: Sheet without detents.
        .bottomSheet(isPresented: $showWithoutDetents) {
            BottomContent() {
                showWithoutDetents.toggle()
            }
        }
        // 3: Sheet that cannot be dismissed by swiping down.
        .bottomSheet(
            isPresented: $showDisableSwipeToDismiss,
            [.height(300), .height(600)],
            selection: $currentDetent
        ) {
            BottomContent() {
                showDisableSwipeToDismiss.toggle()
            }
            .bInteractiveDismissDisabled() // Модификатор закрывает опцию свайпа вних
        }
        // 4: Custom sheet
        .bottomSheet(
            isPresented: $showFullyCustomSheet,
            [.height(200), .height(600)],
            selection: $currentDetent
        ) {
            BottomContent() {
                showFullyCustomSheet.toggle()
            }
            .presentationShadow(radius: 5)
            .presentationOverDragLimit(0) // убираю возможность "оттягивать" кастомную шторку
            .bPresentationDragIndicator(.hidden)
            .bPresentationBackground(Color.yellow)
            .bPresentationCornerRadius(20)
            .presentationContentOverlay(Color.black.opacity(0.5))
        }
        // 5: Sheet with different interactions with the background.
        /**
         ‼️ Due to some limitations in SwiftUI's interaction handling,
            if you use enabled(upThrough:), one of the parameters for detents must be provided!
         ✅ Correct :
         (...
         [.height(100), .medium, .fraction(0.6)],
         interaction: .enabled(upThrough: .medium) <== Here .medium is in detents
         ...
         )
         ❌ Don't use such way:
         (...
         [.height(100), .medium, .fraction(0.6)],
         interaction: .enabled(upThrough: .fraction(0.9)) <== There are no such parameters in the detents!
         ...
         )
         */
        .bottomSheet(
            isPresented: $showSheetWithBackgroundIteraction,
            [.height(100), .medium, .fraction(0.6)],
            interaction: .enabled(upThrough: .medium)
        ) {
            BottomContent() {
                showSheetWithBackgroundIteraction.toggle()
            }
        }
        .nativeBottomSheetDisabled(disableNativeBottomSheet)
        .ignoresSafeArea(edges: .top)
    }
}
