import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test(arguments: [false, true], ["", "\n", WritingCodeFixture.text])
    func codeSourceLinesAndBlockSeamsKeepDistinctCoordinates(
        tagged: Bool, text: String
    ) throws
    {
        let fixture = try WritingCodeFixture.document(text, tagged: tagged)
        let projection = try fixture.projection()
        let document = fixture.state.snapshot.document
        let spans = projection.map.spans
        #expect(spans.count == 3)
        #expect(projection.text.utf16.elementsEqual(
            ("Before\n" + text + "\nAfter").utf16
        ))
        for span in spans
        {
            for local in 0 ... span.range.length
            {
                let offset = span.range.location + local
                let point = try #require(projection.map.point(
                    offset, in: document
                ))
                #expect(point.blockID == span.blockID)
                #expect(point.utf16Offset.value == local)
                #expect(projection.map.offset(point) == offset)
            }
        }
        let inside = try #require(projection.range(spans[1].range))
        #expect(projection.map.separatorCount(in: inside) == 0)
        let all = try #require(projection.range(NSRange(
            location: 0, length: projection.map.utf16Count
        )))
        #expect(projection.map.separatorCount(in: all) == 2)
        try WritingCodeFixture.expect(document.content.blocks[1].block,
                                      text: text, tagged: tagged)
    }

    @Test(arguments: [false, true])
    func codeTraitsAndScopesRemainOutsideThisAdmissionStep(tagged: Bool)
        throws
    {
        let plain = try WritingCodeFixture.block("X", tagged: tagged)
        let editable = try #require(EditableSemanticBlock(plain))
        let language = try #require(SemanticLanguageIdentifier("fr"))
        let scoped = try #require(SemanticInsertion(
            text: "X",
            attributes: .scoped(traits: [], scopes: .language(language))
        )).run
        for run in [SemanticRun(text: "X", traits: [.strong]), scoped]
        {
            let styled = editable.replacingRuns([run])
            let fixture = try WritingTestDocument(blocks: [styled])
            #expect(WritingProjection(fixture.state) == nil)
        }
    }
}
