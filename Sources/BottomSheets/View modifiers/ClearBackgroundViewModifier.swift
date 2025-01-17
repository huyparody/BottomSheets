import SwiftUI

/**
 FullScreenCoverView необходим, чтобы сделать прозрачным fullScreenCover
 
 FullScreenCoverView is needed to make the fullScreenCover transparent.
 */
internal struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    
    var onTapAction: (() -> Void)? = nil
    
    func makeUIView(context: Context) -> UIView {
        return InnerView(onTapAction: onTapAction)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    private class InnerView: UIView {
        var onTapAction: (() -> Void)? = nil
        
        init(onTapAction: (() -> Void)? = nil) {
            self.onTapAction = onTapAction
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            DispatchQueue.main.async { [weak self] in
                self?.superview?.superview?.backgroundColor = .clear
            }
            
            // Добавляем жест на супервью для обработки нажатия
            // Add a gesture to the superview to handle taps.
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            superview?.superview?.addGestureRecognizer(tapGesture)
        }
     
        @objc private func handleTap() {
            onTapAction?()
        }
    }
}

internal struct ClearBackgroundViewModifier: ViewModifier {
    
    var onTapAction: (() -> Void)? = nil
    
    func body(content: Content) -> some View {
        content
            .background(FullScreenCoverBackgroundRemovalView(onTapAction: onTapAction))
    }
}

internal extension View {
   
    func clearModalBackground(_ onTapAction: (() -> Void)? = nil) -> some View {
        modifier(ClearBackgroundViewModifier(onTapAction: onTapAction))
    }
}

