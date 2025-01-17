import Foundation

@frozen public enum BVisibility : Hashable, CaseIterable {
    /// The element may be visible.
    case visible
    
    /// The element may be hidden.
    case hidden
}
