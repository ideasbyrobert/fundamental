import AppKit
import Testing

@MainActor
final class NativeWritingWindow
{
    let window: NSWindow
    let view: NSTextView
    let observer: NativeWritingObserver

    init(_ spelling: String = "")
    {
        _ = NSApplication.shared
        window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 820, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        view = NSTextView(usingTextLayoutManager: true)
        view.frame = NSRect(x: 0, y: 0, width: 820, height: 400)
        view.isRichText = false
        view.allowsUndo = false
        view.smartInsertDeleteEnabled = false
        view.isAutomaticQuoteSubstitutionEnabled = false
        view.isAutomaticDashSubstitutionEnabled = false
        view.isAutomaticTextReplacementEnabled = false
        view.isAutomaticSpellingCorrectionEnabled = false
        view.isAutomaticTextCompletionEnabled = false
        view.writingToolsBehavior = .none
        view.string = spelling
        view.setSelectedRange(NSRange(
            location: spelling.utf16.count,
            length: 0
        ))
        observer = NativeWritingObserver()
        view.delegate = observer
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(view)
        observer.observations = []
    }

    func key(_ spelling: String, code: UInt16) throws
    {
        let event = try #require(NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [],
            timestamp: 1,
            windowNumber: window.windowNumber,
            context: nil,
            characters: spelling,
            charactersIgnoringModifiers: spelling,
            isARepeat: false,
            keyCode: code
        ))
        window.sendEvent(event)
    }

    func expectSpelling(_ spelling: String)
    {
        #expect(view.string.utf16.elementsEqual(spelling.utf16))
        #expect(view.textLayoutManager != nil)
    }

    func expectProposal(
        _ range: NSRange,
        replacement: String,
        before: String
    )
    {
        let proposals = observer.observations.filter(\.isProposal)
        #expect(proposals.count == 1)
        guard case let .proposal(ranges, replacements, spelling, _, _) =
            proposals.first
        else
        {
            Issue.record("native proposal is missing")
            return
        }
        #expect(ranges == [range])
        #expect(replacements == [Array(replacement.utf16)])
        #expect(spelling == Array(before.utf16))
    }
}
