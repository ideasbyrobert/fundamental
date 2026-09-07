import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("paragraph coordinates round trip UTF-16 offsets and empty blocks")
    func paragraphCoordinates() throws
    {
        let fixture = try WritingTestDocument(blocks: ["A", "", "😀", ""].map
        {
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: $0)]))
        })
        let projection = try fixture.projection()
        #expect(projection.text == "A\n\n😀\n")
        #expect(projection.map.utf16Count == 6)
        for offset in 0 ... 6
        {
            let range = try #require(projection.range(NSRange(
                location: offset, length: 0
            )))
            #expect(projection.map.offset(range.start) == offset)
        }
        let spanning = try #require(projection.range(NSRange(
            location: 1, length: 4
        )))
        let selected = try applied(.select(
            projection.observation,
            DocumentSelection(range: try #require(DocumentRange(
                start: spanning.end, end: spanning.start
            )))
        ), to: fixture.state)
        let rebuilt = try #require(WritingProjection(.editable(selected)))
        #expect(rebuilt.selection == NSRange(location: 1, length: 4))
        for range in [NSRange(location: 7, length: 0),
                      NSRange(location: 1, length: Int.max),
                      NSRange(location: NSNotFound, length: 0)]
        {
            #expect(projection.range(range) == nil)
        }
    }

    @Test("paragraph separators count toward the complete projection bound")
    func paragraphCapacity() throws
    {
        for count in [65_535, 65_536]
        {
            let fixture = try WritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: [SemanticRun(
                    text: String(repeating: "A", count: count)
                )])),
                .paragraph(SemanticParagraph(runs: []))
            ])
            let projection = WritingProjection(fixture.state)
            #expect((projection != nil) == (count == 65_535))
        }
    }
}
