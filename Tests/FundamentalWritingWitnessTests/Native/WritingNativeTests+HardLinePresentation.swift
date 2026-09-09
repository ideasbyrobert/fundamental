import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [.body, .heading, .numbered, .bulleted]
        as [CanonicalBlockStyle], ["\n", "\r", "\r\n"])
    func proseHardLinesKeepOneMarkerAndBlockEdgeSpacing(
        style: CanonicalBlockStyle, ending: String
    ) throws
    {
        let source = "First" + ending + "\tSecond" + ending
        let window = try WritingTestWindow(styles: [style, .body],
                                           texts: [source, "After"])
        defer
        {
            window.close()
        }
        #expect(try window.markerLabels() ==
            (style == .numbered ? ["1."] : style == .bulleted ? ["•"] : []))
        let storage = try #require(window.view.textStorage)
        let first = try #require(storage.attribute(.paragraphStyle,
            at: 0, effectiveRange: nil) as? NSParagraphStyle)
        let middle = try #require(storage.attribute(.paragraphStyle,
            at: 5 + ending.utf16.count, effectiveRange: nil)
            as? NSParagraphStyle)
        let last = try #require(storage.attribute(.paragraphStyle,
            at: source.utf16.count, effectiveRange: nil) as? NSParagraphStyle)
        #expect(first.paragraphSpacing == 0)
        #expect(middle.paragraphSpacing == 0)
        #expect(middle.paragraphSpacingBefore == 0)
        #expect(last.paragraphSpacingBefore == 0)
        #expect(last.paragraphSpacing > 0)
        #expect(first.paragraphSpacingBefore == (style == .heading ? 18 : 0))
        window.select(source.utf16.count)
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.controller.documentWindow.setContentSize(NSSize(
            width: 360, height: 420
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        try window.key("X", code: 7)
        let firstBlock = try #require(EditableSemanticBlock(
            window.session.document.content.blocks[0].block
        ))
        #expect(firstBlock.runs.map(\.text).joined().utf16.elementsEqual(
            (source + "X").utf16
        ))
        #expect(window.session.document.content.blocks.count == 2)
    }

    @Test(arguments: ["\n", "\r", "\r\n"])
    func terminalHardLineHasNoSecondListMarker(ending: String) throws
    {
        let source = "One" + ending
        let window = try WritingTestWindow(styles: [.numbered], texts: [source])
        defer
        {
            window.close()
        }
        window.select(source.utf16.count)
        #expect(try window.markerLabels() == ["1."])
        try WritingWindowGeometry.expectVisibleCaret(window)
        try window.key("\r", code: 36)
        #expect(window.styles == [.numbered, .numbered])
        #expect(try window.markerLabels() == ["1.", "2."])
        try window.key("X", code: 7)
        try window.expect(source + (ending == "\r" ? "\r\nX" : "\nX"),
            selection: NSRange(location: source.utf16.count +
                (ending == "\r" ? 3 : 2), length: 0))
    }
}
