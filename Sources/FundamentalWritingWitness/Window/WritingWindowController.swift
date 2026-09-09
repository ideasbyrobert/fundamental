import AppKit
import FundamentalDocument

@MainActor
final class WritingWindowController:
    NSWindowController, NSWindowDelegate, NSUserInterfaceValidations
{
    let documentWindow: NSWindow
    let textView: WritingTextView
    let scrollView: NSScrollView
    let bridge: WritingNativeBridge
    let fileOwner: WritingFileOwner
    let formatting = WritingFormattingToolbar()
    let confirmDiscard: @MainActor () -> WritingCloseDecision
    var discardApproved = false
    var choosingLocation = false
    var closeTask: Task<Bool, Never>?
    var codeLanguageSheet: WritingCodeLanguageSheet?
    var didClose: (@MainActor () -> Void)?

    convenience init?(
        session: DocumentSession,
        size: NSSize = NSSize(width: 820, height: 600),
        confirmDiscard: @escaping @MainActor () -> WritingCloseDecision =
            WritingClosePrompt.ask
    )
    {
        self.init(
            owner: WritingFileOwner(session: session),
            size: size,
            confirmDiscard: confirmDiscard
        )
    }

    init?(
        owner: WritingFileOwner,
        size: NSSize = NSSize(width: 820, height: 600),
        confirmDiscard: @escaping @MainActor () -> WritingCloseDecision =
            WritingClosePrompt.ask
    )
    {
        guard let bridge = WritingNativeBridge(session: owner.session),
              let surface = WritingWindowSurface(size: size, bridge: bridge)
        else
        {
            return nil
        }
        documentWindow = surface.window
        textView = surface.view
        scrollView = surface.scroll
        self.bridge = bridge
        self.fileOwner = owner
        self.confirmDiscard = confirmDiscard
        super.init(window: surface.window)
        formatting.install(in: surface.window)
        surface.window.delegate = self
        bridge.didChange = { [weak self] in self?.updateDocumentState() }
        owner.didChange = { [weak self] in self?.updateDocumentState() }
        updateDocumentState()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder)
    {
        return nil
    }
}
