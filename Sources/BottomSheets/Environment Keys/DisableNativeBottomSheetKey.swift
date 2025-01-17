import SwiftUI

@available(iOS, deprecated: 16.0, message: "Since iOS 16 provides a native bottom sheet, using this flag is pointless.")
struct DisableNativeBottomSheetKey: EnvironmentKey {
    static let defaultValue = false
}

@available(iOS, deprecated: 16.0, message: "Since iOS 16 provides a native bottom sheet, using this flag is pointless.")
public extension EnvironmentValues {

    var disableNativeBottomSheet: Bool {
        get { self[DisableNativeBottomSheetKey.self] }
        set { self[DisableNativeBottomSheetKey.self] = newValue }
    }
}

public extension View {
    
    @available(iOS, deprecated: 16.0, message: "Since iOS 16 provides a native bottom sheet, using this flag is pointless.")
    func nativeBottomSheetDisabled(_ isDisabled: Bool = true) -> some View {
        environment(\.disableNativeBottomSheet, isDisabled)
    }
}
