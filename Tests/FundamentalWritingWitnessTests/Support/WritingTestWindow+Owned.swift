import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingTestWindow
{
    init(
        owner: WritingFileOwner,
        decision: @escaping @MainActor () -> WritingCloseDecision = { .cancel }
    ) throws
    {
        try #require(Thread.isMainThread)
        _ = NSApplication.shared
        session = owner.session
        controller = try #require(WritingWindowController(
            owner: owner, confirmDiscard: decision
        ))
        controller.documentWindow.animationBehavior = .none
        controller.showWindow(nil)
    }
}
