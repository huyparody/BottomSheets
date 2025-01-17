import SwiftUI

struct PresentationCornerRadiusPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue()
    }
}

public extension View {
    
    @available(iOS, deprecated: 16.4, message: "Use native presentationCornerRadius() to set a specific corner radius for a bottom sheet.")
    func bPresentationCornerRadius(_ cornerRadius: CGFloat?) -> some View {
        preference(key: PresentationCornerRadiusPreferenceKey.self, value: cornerRadius)
    }
}
