import SwiftUI

@available(iOS 16.4, *)
struct NativeBottoms: View {
    @State private var isPresented: Bool = false
    @State private var disableSwipeToDismiss: Bool = false
    
    @State private var currentDetent: PresentationDetent = .medium

    @State private var bgColor: Color = .yellow
    
    // Enable Presentation Background Interaction
    @State private var interaction: Bool = false
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.5)
            VStack(spacing: 20.0) {
                Text("Native bottom sheet")
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
                    Text("Show bottom sheet")
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
            .padding(16)
        }
        .ignoresSafeArea(edges: .top)
    }
}
