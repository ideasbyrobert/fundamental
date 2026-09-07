import Foundation
import FundamentalDocument
import Testing

struct WritingMeasurementCorpus
{
    let document: CanonicalDocument
    let utf16Count: Int
    let paragraphCount: Int

    init(paragraphs count: Int) throws
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
            return IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(UUID()),
                block: .paragraph(SemanticParagraph(runs: [insertion.run]))
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
    }
}
