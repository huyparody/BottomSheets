import SwiftUI

struct PresentationOverDragLimitPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 50.0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public extension View {
    
    // Доступно только для custom bottom sheet возможность установить эффект оттягивания шторки
    // Allows you to set the pull-back effect (Available only for custom bottom sheets)
    func presentationOverDragLimit(_ limit: CGFloat) -> some View {
        preference(key: PresentationOverDragLimitPreferenceKey.self, value: limit)
    }
}
