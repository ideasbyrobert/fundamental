import Foundation
import Testing

@testable import FundamentalDocument

struct WritingMeasurementCorpus
{
    let document: CanonicalDocument
    let utf16Count: Int
    let paragraphCount: Int
    let semantic: Bool

    init(paragraphs count: Int, semantic: Bool = false) throws
    {
        try #require((1 ... 16_384).contains(count))
        let sentence = "A manuscript paragraph keeps ordinary words, " +
            "123, e\u{301}, and 👩🏽‍💻 together. "
        let text = String(repeating: sentence, count: 6)
        let blocks = try (0 ..< count).map
        {
            index in
            let marker = ("00000" + String(index)).suffix(5)
            let insertion = try #require(SemanticInsertion(
                text: "A \(marker) " + text, attributes: .direct(traits: [])
            ))
            let styles: [CanonicalBlockStyle] = [
                .heading, .body, .bulleted, .bulleted, .subheading,
                .body, .numbered, .numbered, .numbered, .body
            ]
            let style = semantic ? (index == 0 ? .title :
                styles[index % styles.count]) : .body
            return IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(UUID()),
                block: style.semanticBlock(runs: [insertion.run])
            )
        }
        let first = try #require(blocks.first)
        document = CanonicalDocument(
            documentID: FundamentalDocumentID(UUID()), revision: .zero,
            content: try #require(CanonicalDocumentContent(
                firstBlock: first, remainingBlocks: Array(blocks.dropFirst())
            ))
        )
        utf16Count = (text.utf16.count + 8) * count + count - 1
        paragraphCount = count
        self.semantic = semantic
    }
}
