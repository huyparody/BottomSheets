import SwiftUI

struct PresentationContentOverlayPreferenceKey: PreferenceKey {
    static var defaultValue: Color = Color.black.opacity(0.5)

    static func reduce(value: inout Color, nextValue: () -> Color) {
        value = nextValue()
    }
}

public extension View {
    
    // Доступно только для custom bottom sheet регулирует затемнение контента
    // Adjusts the content dimming (Available only for custom bottom sheets)
    func presentationContentOverlay(_ color: Color) -> some View {
        preference(key: PresentationContentOverlayPreferenceKey.self, value: color)
    }
}
