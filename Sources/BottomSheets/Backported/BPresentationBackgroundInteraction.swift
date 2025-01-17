import SwiftUI

@available(iOS, deprecated: 16.4, message: "Use native PresentationBackgroundInteraction")
public struct BPresentationBackgroundInteraction : Equatable, Hashable, Sendable {
    enum InteractionType: Equatable, Hashable, Sendable {
        case automatic
        case enabled
        case enabledUpThrough(BPresentationDetent)
        case disabled
    }
    
    let type: InteractionType
    
    /// The default background interaction for the presentation.
    public static let automatic = BPresentationBackgroundInteraction(type: .automatic)
    /// People can interact with the view behind a presentation.
    public static let enabled = BPresentationBackgroundInteraction(type: .enabled)

    /// People can interact with the view behind a presentation up through a
    /// specified detent.
    ///
    /// At detents larger than the one you specify, SwiftUI disables
    /// interaction.
    ///
    /// - Parameter detent: The largest detent at which people can interact with
    ///   the view behind the presentation.
    public static func enabled(upThrough detent: BPresentationDetent) -> BPresentationBackgroundInteraction {
        return BPresentationBackgroundInteraction(type: .enabledUpThrough(detent))
    }

    /// People can't interact with the view behind a presentation.
    public static let disabled = BPresentationBackgroundInteraction(type: .disabled)
}

extension BPresentationBackgroundInteraction {
    @available(iOS 16.4, *)
    var toSUI: PresentationBackgroundInteraction {
        switch type {
        case .automatic:
            return .automatic
        case .enabled:
            return .enabled
        case .enabledUpThrough(let detent):
            return .enabled(upThrough: detent.toPresentationDetent)
        case .disabled:
            return .disabled
        }
    }
}
