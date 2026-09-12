import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingTextInterchangeTests
{
    @Test("export uses canonical text and LF between semantic blocks")
    func canonicalExport() throws
    {
        let document = try WritingTestDocument(blocks: [
            CanonicalBlockStyle.title.semanticBlock(runs: [
                SemanticRun(text: "Heading", traits: [.strong])
            ]),
            .listItem(SemanticListItem(kind: .numbered,
                runs: [SemanticRun(text: "First")])),
            .listItem(SemanticListItem(kind: .bulleted,
                runs: [SemanticRun(text: "Second")])),
            WritingCodeFixture.block("\tlet x = 1\r\n\n\r", tagged: true),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "End")]))
        ]).projection().snapshot.snapshot.document
        let expected = "Heading\nFirst\nSecond\n\tlet x = 1\r\n\n\r\nEnd"
        let exported = try WritingTextExport.data(from: document)
        #expect(exported == Data(expected.utf8))
    }

    @Test("only bare LF introduces an imported semantic paragraph")
    func paragraphBoundaries() throws
    {
        let imported = try WritingTextImport(Data("A\r\nB\rC\n\nD\n".utf8))
        let projection = try #require(WritingProjection(imported.state))
        let texts = projection.snapshot.snapshot.document.content.blocks.map
        {
            EditableSemanticBlock($0.block)?.runs.map(\.text).joined()
        }
        #expect(texts == ["A\r\nB\rC", "", "D", ""])
        #expect(Set(projection.map.spans.map(\.blockID)).count == 4)
    }
}
