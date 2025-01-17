import SwiftUI

struct PresentationShadowData: Equatable {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    // Реализация Equatable: сравниваем только alignment, так как AnyView не поддерживает Equatable
    // Equatable implementation: compare only alignment, as AnyView does not support Equatable.
    static func == (lhs: PresentationShadowData, rhs: PresentationShadowData) -> Bool {
        lhs.color == rhs.color && lhs.radius == rhs.radius && lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static let `default` = PresentationShadowData(
        color: Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: 10,
        x: 0,
        y: 0
    )
}

struct PresentationShadowDataPreferenceKey: PreferenceKey {
    static var defaultValue: PresentationShadowData? { nil }

    static func reduce(value: inout PresentationShadowData?, nextValue: () -> PresentationShadowData?) {
        value = nextValue() ?? value
    }
}

public extension View {
    
    // Доступно только для custom bottom sheet возможность установить эффект тени для шторки
    // allows setting a shadow effect for the sheet (Available only for custom bottom sheets)
    func presentationShadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> some View {
        preference(
            key: PresentationShadowDataPreferenceKey.self,
            value: PresentationShadowData(
                color: color,
                radius: radius,
                x: x,
                y: y
            )
        )
    }
}
