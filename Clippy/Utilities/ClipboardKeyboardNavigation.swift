import Foundation
import CoreGraphics

enum ClipboardKeyboardNavigation {
    enum ScrollDirection: Equatable {
        case up
        case down
    }

    enum ScrollEdge: Equatable {
        case top
        case bottom
    }

    enum ScrollIntent: Equatable {
        case movement(ScrollDirection)
        case wrap(to: ScrollEdge)
        case boundary(ScrollEdge)

        fileprivate var fallbackEdge: ScrollEdge {
            switch self {
            case .movement(.up):
                return .top
            case .movement(.down):
                return .bottom
            case let .wrap(edge), let .boundary(edge):
                return edge
            }
        }

        fileprivate var shouldAnimate: Bool {
            if case .movement = self {
                return true
            }
            return false
        }
    }

    enum ScrollDecision: Equatable {
        case noScroll
        case scroll(to: ScrollEdge, animated: Bool)
    }

    /// Chooses the smallest directional scroll needed to reveal a keyboard target.
    ///
    /// Frames are expected in the same coordinate space as `visibleTop` and
    /// `visibleBottom`. Missing frames are normal for lazily measured offscreen
    /// rows, so the navigation intent provides the fallback alignment.
    static func scrollDecision(
        targetFrame: CGRect?,
        visibleTop: CGFloat,
        visibleBottom: CGFloat,
        intent: ScrollIntent,
        visibilityTolerance: CGFloat = 1
    ) -> ScrollDecision {
        switch intent {
        case let .wrap(edge), let .boundary(edge):
            return .scroll(to: edge, animated: false)
        case .movement:
            break
        }

        guard
            let targetFrame,
            !targetFrame.isNull,
            !targetFrame.isInfinite
        else {
            return .scroll(to: intent.fallbackEdge, animated: intent.shouldAnimate)
        }

        let tolerance = max(0, visibilityTolerance)
        let isFullyVisible = targetFrame.minY >= visibleTop - tolerance
            && targetFrame.maxY <= visibleBottom + tolerance
        if isFullyVisible {
            return .noScroll
        }

        let edge: ScrollEdge
        if targetFrame.minY < visibleTop - tolerance {
            edge = .top
        } else if targetFrame.maxY > visibleBottom + tolerance {
            edge = .bottom
        } else {
            edge = intent.fallbackEdge
        }

        return .scroll(to: edge, animated: intent.shouldAnimate)
    }

    static func actionItemId(
        hoveredId: UUID?,
        selectedId: UUID?,
        itemIds: [UUID],
        isQuickLookPresented: Bool,
        isQueueTabSelected: Bool
    ) -> UUID? {
        guard !isQuickLookPresented, !isQueueTabSelected else {
            return nil
        }

        let activeId = hoveredId ?? selectedId
        guard let activeId else {
            return itemIds.first
        }

        return itemIds.contains(activeId) ? activeId : itemIds.first
    }

    static func validSelectionId(
        selectedId: UUID?,
        itemIds: [UUID],
        isQueueTabSelected: Bool
    ) -> UUID? {
        guard !isQueueTabSelected, !itemIds.isEmpty else {
            return nil
        }

        if let selectedId, itemIds.contains(selectedId) {
            return selectedId
        }

        return itemIds.first
    }

    static func initialPresentationSelectionId(
        itemIds: [UUID],
        isQueueTabSelected: Bool
    ) -> UUID? {
        guard !isQueueTabSelected else {
            return nil
        }

        return itemIds.first
    }

    static func nextSelectionId(
        selectedId: UUID?,
        hoveredId: UUID?,
        itemIds: [UUID],
        offset: Int,
        isQuickLookPresented: Bool,
        isQueueTabSelected: Bool
    ) -> UUID? {
        guard !isQuickLookPresented, !isQueueTabSelected, !itemIds.isEmpty else {
            return nil
        }

        let currentId: UUID?
        if let hoveredId, itemIds.contains(hoveredId) {
            currentId = hoveredId
        } else if let selectedId, itemIds.contains(selectedId) {
            currentId = selectedId
        } else {
            currentId = nil
        }
        let currentIndex = currentId.flatMap { itemIds.firstIndex(of: $0) } ?? (offset > 0 ? -1 : itemIds.count)
        let nextIndex = (currentIndex + offset + itemIds.count) % itemIds.count

        return itemIds[nextIndex]
    }

    static func boundarySelectionId(
        itemIds: [UUID],
        selectLast: Bool,
        isQuickLookPresented: Bool,
        isQueueTabSelected: Bool
    ) -> UUID? {
        guard !isQuickLookPresented, !isQueueTabSelected else {
            return nil
        }

        return selectLast ? itemIds.last : itemIds.first
    }
}
