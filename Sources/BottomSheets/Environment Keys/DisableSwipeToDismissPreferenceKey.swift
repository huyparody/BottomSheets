import SwiftUI

@available(iOS, deprecated: 16.0, message: "Since iOS 16 provides a native bottom sheet, using this PreferenceKey is pointless.")
struct DisableSwipeToDismissPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

public extension View {
    
    /// `bInteractiveDismissDisabled` backported interactiveDismissDisabled to conditionally prevents interactive dismissal of presentations like popovers, sheets, and inspectors.
    @available(iOS, deprecated: 16.0, message: "Use native interactiveDismissDisabled(_:) to conditionally prevents interactive dismissal of presentations like popovers, sheets, and inspectors.")
    func bInteractiveDismissDisabled(_ isDisabled: Bool = true) -> some View {
        preference(key: DisableSwipeToDismissPreferenceKey.self, value: isDisabled)
    }
}
