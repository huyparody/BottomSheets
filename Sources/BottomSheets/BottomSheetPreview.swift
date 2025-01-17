import SwiftUI

internal struct BottomContent: View {
    
    let action: () -> Void
    
    var body: some View {
        VStack {
            Button {
                action()
            } label: {
                Text("Close")
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    Text("Welcome to your personalized dashboard!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    // Subheader
                    Text(
                        "Here’s an overview of your recent activity and progress:"
                    )
                    .font(.headline)
                    .foregroundColor(.secondary)
                    
                    // Section 1: Tasks
                    Text("Tasks")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📌 Complete the \"User Feedback Analysis\"")
                        Text("📌 Schedule a team meeting for Q1 planning")
                        Text("📌 Review the draft for the new project proposal")
                    }
                    .padding(.leading, 16)
                    
                    // Section 2: Statistics
                    Text("Statistics")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🚀 Project completion rate: 76%")
                        Text("📈 Weekly active users: 12,340")
                        Text("⏱ Average response time: 2.3s")
                    }
                    .padding(.leading, 16)
                    
                    // Section 3: Notifications
                    Text("Notifications")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🛠 Scheduled maintenance on January 20, 2025.")
                        Text(
                            "🎉 You’ve unlocked a new achievement: \"Top Collaborator.\""
                        )
                        Text("🔔 Your subscription renews in 3 days.")
                    }
                    .padding(.leading, 16)
                    
                    // Footer
                    Spacer().frame(height: 32)
                    Text("Stay productive and have a great day! 😊")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

internal struct BottomSheetPreview: View {
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
            Color.blue.opacity(0.5)
            ScrollView {
                VStack(spacing: 40.0) {
                    Text("Bottom sheets demo")
                        .font(.title)
                    
                    Text("current detent: \(currentDetent)")
                    
                    Toggle(isOn: $disableNativeBottomSheet) {
                        Text("Disable SwiftUI Bottom sheet (since iOS 16)")
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
                            Text("Шторка с разным взаимодействием с фоном")
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
            [.height(200), .height(300)],
            selection: $currentDetent
        ) {
            BottomContent() {
                showFullyCustomSheet.toggle()
            }
            .presentationShadow(radius: 5)
            .presentationOverDragLimit(0) // убираю возможность "оттягивать" кастомную шторку
            .bPresentationDragIndicator(.hidden)
            .bPresentationBackground(Color.blue)
            .bPresentationCornerRadius(20)
            .presentationContentOverlay(Color.red.opacity(0.5))
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

#Preview {
    BottomSheetPreview()
}

@available(iOS 16.4, *)
struct NativeBottomSheet_Previews: PreviewProvider {
    
    struct Container: View {
        @State private var isPresented: Bool = false
        @State private var disableSwipeToDismiss: Bool = false
        
        @State private var currentDetent: PresentationDetent = .medium
        
        @State private var bgColor: Color = .yellow.opacity(0.3)
        
        // Enable Presentation Background Interaction
        @State private var interaction: Bool = false
        
        var body: some View {
            ZStack {
                Color.blue.opacity(0.5)
                VStack(spacing: 20.0) {
                    Text("Нативная шторка из коробки")
                        .font(.title)
                    
                    Text("Selected detent: \(currentDetent)")
                    
                    Toggle(isOn: $disableSwipeToDismiss) {
                        Text("Disable swipe to dismiss")
                    }
                    .padding()
                    
                    Toggle(isOn: $interaction) {
                        Text("Presentation Background Interaction ")
                    }
                    .padding(.horizontal)
                    
                    
                    Button {
                        isPresented.toggle()
                    } label: {
                        Text("Показать шторку")
                    }
                    
                    Spacer()
                }
                .padding(.top, 100)
            }
            .sheet(isPresented: $isPresented) {
                BottomContent() {
                    isPresented.toggle()
                }
                .presentationBackground {
                    bgColor
                }
                .presentationDetents(
                    [.medium, .fraction(0.7)],
                    selection: $currentDetent
                )
                .presentationBackgroundInteraction(interaction ? .enabled(upThrough: .medium) : .disabled)
                .interactiveDismissDisabled(disableSwipeToDismiss)
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea()
        }
    }
    
    static var previews: some View {
        Container()
            .previewDisplayName("iOS 16 BottomSheet native")
    }
}
