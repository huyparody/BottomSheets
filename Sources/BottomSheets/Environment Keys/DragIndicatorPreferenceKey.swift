import SwiftUI

@available(iOS, deprecated: 16.0, message: "Since iOS 16 provides a native bottom sheet, using this PreferenceKey is pointless.")
struct DragIndicatorPreferenceKey: PreferenceKey {
    static var defaultValue: BVisibility = .visible
    
    static func reduce(value: inout BVisibility, nextValue: () -> BVisibility) {
        if nextValue() == .visible {
            value = .visible
        }
    }
}

public extension View {
    
    @available(iOS, deprecated: 16.0, message: "Use native presentationDragIndicator(_:) to set the visibility of the drag indicator on top of a sheet.")
    func bPresentationDragIndicator( _ visibility: BVisibility) -> some View {
        preference(key: DragIndicatorPreferenceKey.self, value: visibility)
    }
}
