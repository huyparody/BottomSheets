import SwiftUI

struct PresentationBackgroundPreferenceKey: PreferenceKey {
    static var defaultValue: Color = Color.white

    static func reduce(value: inout Color, nextValue: () -> Color) {
        value = nextValue()
    }
}

public extension View {
    
    @available(iOS, deprecated: 16.4, message: "Use native presentationBackground() to set the presentation background of the enclosing sheet to a custom view.")
    func bPresentationBackground(_ color: Color) -> some View {
        preference(key: PresentationBackgroundPreferenceKey.self, value: color)
    }
}
