import AppKit

@testable import FundamentalWritingWitness

extension WritingTestWindow
{
    func mark(
        _ text: String,
        replacing range: NSRange = NSRange(location: NSNotFound, length: 0),
        selecting selection: NSRange? = nil
    )
    {
        view.setMarkedText(
            text,
            selectedRange: selection ?? NSRange(location: text.utf16.count,
                                                 length: 0),
            replacementRange: range
        )
    }

    func commit(_ text: String)
    {
        view.insertText(text, replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
    }
}
