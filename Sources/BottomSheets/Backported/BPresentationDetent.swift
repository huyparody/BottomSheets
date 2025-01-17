import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use native PresentationDetent")
public struct BPresentationDetent: Equatable, Hashable, CustomStringConvertible, Sendable {
    
    private enum DetentType: Equatable, Hashable {
        case medium
        case large
        case fraction(CGFloat)
        case height(CGFloat)
    }

    private let type: DetentType

    // Medium detent
    public static let medium = BPresentationDetent(type: .medium)
    
    // Large detent
    public static let large = BPresentationDetent(type: .large)

    // Статические методы для создания детентов с дробной высотой и фиксированной высотой
    // Static methods for creating detents with fractional height and fixed height
    public static func fraction(_ fraction: CGFloat) -> BPresentationDetent {
        return BPresentationDetent(type: .fraction(fraction))
    }

    public static func height(_ height: CGFloat) -> BPresentationDetent {
        return BPresentationDetent(type: .height(height))
    }

    // Метод для вычисления высоты детента на основе высоты контейнера
    // Method for calculating the detent height based on the container height
    public func height(in containerHeight: CGFloat) -> CGFloat {
        switch type {
        case .medium:
            return containerHeight * 0.5
        case .large:
            return containerHeight
        case .fraction(let fraction):
            return containerHeight * fraction
        case .height(let height):
            return height
        }
    }

    // Метод для сравнения двух детентов с учетом высоты контейнера
    // Method for comparing two detents relative to the container height
    public func compare(to other: BPresentationDetent, in containerHeight: CGFloat) -> ComparisonResult {
        let lhsHeight = self.height(in: containerHeight)
        let rhsHeight = other.height(in: containerHeight)
        
        if lhsHeight < rhsHeight {
            return .orderedAscending
        } else if lhsHeight > rhsHeight {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
    
    // Свойство description для соответствия CustomStringConvertible
    // A description property to conform to CustomStringConvertible
    public var description: String {
        switch type {
        case .medium:
            return "medium"
        case .large:
            return "large"
        case .fraction(let fraction):
            return String(format: "fraction(%.2f)", fraction)
        case .height(let height):
            return "height(\(height))"
        }
    }
}

@available(iOS, deprecated: 16.0, message: "Use native PresentationDetent")
extension Set where Element == BPresentationDetent {
    func sortedByHeight(in containerHeight: CGFloat) -> [BPresentationDetent] {
        return self.sorted { first, second in
            first.height(in: containerHeight) < second.height(in: containerHeight)
        }
    }
}

extension BPresentationDetent {
    @available(iOS 16.0, *)
    var toPresentationDetent: PresentationDetent {
        switch type {
        case .medium:
            return .medium
        case .large:
            return .large
        case .fraction(let fraction):
            return .fraction(fraction)
        case .height(let height):
            return .height(height)
        }
    }
}
