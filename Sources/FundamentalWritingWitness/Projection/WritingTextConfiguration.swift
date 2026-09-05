import AppKit

@MainActor
struct WritingTextConfiguration
{
    static func apply(to view: WritingTextView) -> Bool
    {
        let base = NSFont.systemFont(ofSize: 20)
        guard view.textLayoutManager != nil,
              let descriptor = base.fontDescriptor.withDesign(.serif),
              let font = NSFont(descriptor: descriptor, size: 20),
              let container = view.textContainer
        else
        {
            return false
        }
        view.isRichText = false
        view.importsGraphics = false
        view.allowsUndo = false
        view.smartInsertDeleteEnabled = false
        view.isAutomaticQuoteSubstitutionEnabled = false
        view.isAutomaticDashSubstitutionEnabled = false
        view.isAutomaticTextReplacementEnabled = false
        view.isAutomaticSpellingCorrectionEnabled = false
        view.isAutomaticTextCompletionEnabled = false
        view.isAutomaticLinkDetectionEnabled = false
        view.isAutomaticDataDetectionEnabled = false
        view.isContinuousSpellCheckingEnabled = false
        view.isGrammarCheckingEnabled = false
        view.writingToolsBehavior = .none
        view.font = font
        view.textColor = .textColor
        view.backgroundColor = .textBackgroundColor
        view.insertionPointColor = .textColor
        view.isVerticallyResizable = true
        view.isHorizontallyResizable = false
        view.autoresizingMask = [.width]
        view.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        container.widthTracksTextView = true
        container.heightTracksTextView = false
        container.lineFragmentPadding = 0
        view.setAccessibilityLabel("Fundamental document")
        return true
    }
}
