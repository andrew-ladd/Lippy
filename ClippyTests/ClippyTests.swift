//
//  ClippyTests.swift
//  ClippyTests
//
//  Created by Jnani Smart on 22/03/25.
//

import Foundation
import Testing
@testable import Clippy

struct ClipboardKeyboardNavigationTests {
    private let itemIds = [
        UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    ]
    private let missingItemId = UUID(uuidString: "00000000-0000-0000-0000-000000000099")!

    @Test func downArrowWithoutSelectionStartsAtFirstItem() {
        let nextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: nil,
            hoveredId: nil,
            itemIds: itemIds,
            offset: 1,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(nextId == itemIds[0])
    }

    @Test func upArrowWithoutSelectionStartsAtLastItem() {
        let nextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: nil,
            hoveredId: nil,
            itemIds: itemIds,
            offset: -1,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(nextId == itemIds[2])
    }

    @Test func downArrowWrapsFromLastItemToFirstItem() {
        let nextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: itemIds[2],
            hoveredId: nil,
            itemIds: itemIds,
            offset: 1,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(nextId == itemIds[0])
    }

    @Test func upArrowWrapsFromFirstItemToLastItem() {
        let nextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: itemIds[0],
            hoveredId: nil,
            itemIds: itemIds,
            offset: -1,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(nextId == itemIds[2])
    }

    @Test func hoveredItemIsUsedWhenNoKeyboardSelectionExists() {
        let nextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: nil,
            hoveredId: itemIds[1],
            itemIds: itemIds,
            offset: 1,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(nextId == itemIds[2])
    }

    @Test func hoveredItemWinsWhenKeyboardSelectionIsStale() {
        let nextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: itemIds[0],
            hoveredId: itemIds[1],
            itemIds: itemIds,
            offset: 1,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(nextId == itemIds[2])
    }

    @Test func staleHoveredItemFallsBackToValidKeyboardSelection() {
        let nextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: itemIds[0],
            hoveredId: missingItemId,
            itemIds: itemIds,
            offset: 1,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(nextId == itemIds[1])
    }

    @Test func actionItemPrefersHoveredItemOverKeyboardSelection() {
        let actionId = ClipboardKeyboardNavigation.actionItemId(
            hoveredId: itemIds[1],
            selectedId: itemIds[0],
            itemIds: itemIds,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(actionId == itemIds[1])
    }

    @Test func actionItemUsesSelectionWhenThereIsNoHover() {
        let actionId = ClipboardKeyboardNavigation.actionItemId(
            hoveredId: nil,
            selectedId: itemIds[1],
            itemIds: itemIds,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(actionId == itemIds[1])
    }

    @Test func actionItemFallsBackToFirstItemWhenActiveItemIsStale() {
        let actionId = ClipboardKeyboardNavigation.actionItemId(
            hoveredId: missingItemId,
            selectedId: nil,
            itemIds: itemIds,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(actionId == itemIds[0])
    }

    @Test func actionItemIsDisabledForQueueTabAndQuickLook() {
        let queueActionId = ClipboardKeyboardNavigation.actionItemId(
            hoveredId: itemIds[0],
            selectedId: nil,
            itemIds: itemIds,
            isQuickLookPresented: false,
            isQueueTabSelected: true
        )
        let quickLookActionId = ClipboardKeyboardNavigation.actionItemId(
            hoveredId: itemIds[0],
            selectedId: nil,
            itemIds: itemIds,
            isQuickLookPresented: true,
            isQueueTabSelected: false
        )

        #expect(queueActionId == nil)
        #expect(quickLookActionId == nil)
    }

    @Test func invalidSelectionFallsBackToFirstItem() {
        let validId = ClipboardKeyboardNavigation.validSelectionId(
            selectedId: missingItemId,
            itemIds: itemIds,
            isQueueTabSelected: false
        )

        #expect(validId == itemIds[0])
    }

    @Test func presentationSelectionAlwaysStartsAtFirstItem() {
        let initialId = ClipboardKeyboardNavigation.initialPresentationSelectionId(
            itemIds: itemIds,
            isQueueTabSelected: false
        )

        #expect(initialId == itemIds[0])
    }

    @Test func presentationSelectionIsDisabledForQueueTab() {
        let initialId = ClipboardKeyboardNavigation.initialPresentationSelectionId(
            itemIds: itemIds,
            isQueueTabSelected: true
        )

        #expect(initialId == nil)
    }

    @Test func navigationIsDisabledForQueueTabAndQuickLook() {
        let queueNextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: itemIds[0],
            hoveredId: nil,
            itemIds: itemIds,
            offset: 1,
            isQuickLookPresented: false,
            isQueueTabSelected: true
        )
        let quickLookNextId = ClipboardKeyboardNavigation.nextSelectionId(
            selectedId: itemIds[0],
            hoveredId: nil,
            itemIds: itemIds,
            offset: 1,
            isQuickLookPresented: true,
            isQueueTabSelected: false
        )

        #expect(queueNextId == nil)
        #expect(quickLookNextId == nil)
    }

    @Test func commandArrowSelectsRequestedBoundary() {
        let firstId = ClipboardKeyboardNavigation.boundarySelectionId(
            itemIds: itemIds,
            selectLast: false,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )
        let lastId = ClipboardKeyboardNavigation.boundarySelectionId(
            itemIds: itemIds,
            selectLast: true,
            isQuickLookPresented: false,
            isQueueTabSelected: false
        )

        #expect(firstId == itemIds.first)
        #expect(lastId == itemIds.last)
    }

    @Test func boundaryNavigationIsDisabledForQueueTabAndQuickLook() {
        let queueId = ClipboardKeyboardNavigation.boundarySelectionId(
            itemIds: itemIds,
            selectLast: false,
            isQuickLookPresented: false,
            isQueueTabSelected: true
        )
        let quickLookId = ClipboardKeyboardNavigation.boundarySelectionId(
            itemIds: itemIds,
            selectLast: true,
            isQuickLookPresented: true,
            isQueueTabSelected: false
        )

        #expect(queueId == nil)
        #expect(quickLookId == nil)
    }
}
