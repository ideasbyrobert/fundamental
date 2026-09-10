import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle

extension MacReaderListTests
{
    @Test("native attributed text preserves scalar boundaries and list context",
          arguments: SemanticListKind.allCases)
    func accessibilityRanges(kind: SemanticListKind) throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderListFixture.block(kind, "First"),
            MacReaderListFixture.block(kind, "A😀B")
        ])
        let controller = try MacReaderDocumentFixture.window(source)
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let groups = try MacReaderListFixture.groups(controller.readerView)
        let group = try #require(groups.last)
        let children = try MacReaderListFixture.children(group)
        let body = try #require(children.last)
        for (range, text) in [
            (NSRange(location: 0, length: 4), "A😀B"),
            (NSRange(location: 1, length: 2), "😀"),
            (NSRange(location: 3, length: 1), "B"),
            (NSRange(location: 1, length: 0), ""),
            (NSRange(location: 4, length: 0), "")
        ]
        {
            let value = try #require(
                body.accessibilityAttributedString(for: range)
            )
            #expect(value.string == text)
            if !text.isEmpty
            {
                let index = value.attribute(
                    .accessibilityListItemIndex, at: 0, effectiveRange: nil
                ) as? NSNumber
                #expect(index?.intValue == 1)
            }
        }
        for range in [
            NSRange(location: -1, length: 0),
            NSRange(location: 0, length: -1),
            NSRange(location: NSNotFound, length: 0),
            NSRange(location: 1, length: Int.max),
            NSRange(location: 0, length: 5),
            NSRange(location: 2, length: 0),
            NSRange(location: 0, length: 2),
            NSRange(location: 2, length: 2),
            NSRange(location: 1, length: 1)
        ]
        {
            #expect(body.accessibilityAttributedString(for: range) == nil)
        }
        #expect(body.accessibilityAttributeValue(.value) as? String == "A😀B")
    }
}
