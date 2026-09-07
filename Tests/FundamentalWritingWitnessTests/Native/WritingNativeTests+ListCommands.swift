import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native Return continues each list and an empty item ends it")
    func listReturn() throws
    {
        for style in [CanonicalBlockStyle.bulleted, .numbered]
        {
            let window = try WritingTestWindow(
                styles: [style], texts: ["First"]
            )
            defer
            {
                window.close()
            }
            window.select(5)
            try window.key("\r", code: 36)
            #expect(window.styles == [style, style])
            let caret = NSRange(location: 6, length: 0)
            try window.expect("First\n", selection: caret)
            try window.key("\r", code: 36)
            #expect(window.styles == [style, .body])
            try window.expect("First\n", selection: caret)
            window.view.undoCanonicalEdit(nil)
            #expect(window.styles == [style, style])
            window.view.undoCanonicalEdit(nil)
            #expect(window.styles == [style])
            #expect(window.view.string == "First")
        }
    }

    @Test("Backspace removes list meaning before joining preceding text")
    func listBackspace() throws
    {
        let window = try WritingTestWindow(
            styles: [.body, .numbered], texts: ["Before", "After"]
        )
        defer
        {
            window.close()
        }
        window.select(7)
        try window.key("\u{7F}", code: 51)
        #expect(window.styles == [.body, .body])
        #expect(window.view.string == "Before\nAfter")
        try window.key("\u{7F}", code: 51)
        #expect(window.styles == [.body])
        #expect(window.view.string == "BeforeAfter")
        window.view.undoCanonicalEdit(nil)
        window.view.undoCanonicalEdit(nil)
        #expect(window.styles == [.body, .numbered])
    }

    @Test("Return after a heading creates body text and typing attributes")
    func headingReturn() throws
    {
        let window = try WritingTestWindow(styles: [.title], texts: ["Title"])
        defer
        {
            window.close()
        }
        window.select(5)
        try window.key("\r", code: 36)
        #expect(window.styles == [.title, .body])
        let font = window.view.typingAttributes[.font] as? NSFont
        #expect(font?.pointSize == 20)
        try window.key("B", code: 11)
        #expect(window.view.string == "Title\nB")
    }
}
