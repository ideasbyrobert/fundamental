import Foundation
import FundamentalDocument

struct WritingTextImport: Sendable
{
    static let maximumBytes = WritingSurfacePolicy.maximumUTF16Units * 3 + 3
    let state: DocumentSessionState

    init(_ data: Data) throws
    {
        guard data.count <= Self.maximumBytes
        else
        {
            throw WritingTextFailure.excessiveText
        }
        let payload = data.starts(with: [0xEF, 0xBB, 0xBF])
            ? data.dropFirst(3) : data[...]
        guard let text = String(validating: payload, as: UTF8.self)
        else
        {
            throw WritingTextFailure.invalidUTF8
        }
        guard WritingSurfacePolicy.admits(text)
        else
        {
            throw WritingTextFailure.excessiveText
        }
        let paragraphs = text.split(separator: "\n",
                                     omittingEmptySubsequences: false)
        guard paragraphs.count <= WritingSurfacePolicy.maximumParagraphs
        else
        {
            throw WritingTextFailure.excessiveText
        }
        let blocks = paragraphs.map
        {
            IdentifiedSemanticBlock(blockID: FundamentalBlockID(UUID()),
                block: .paragraph(SemanticParagraph(
                    runs: [SemanticRun(text: String($0),
                                        attributes: .direct(traits: []))]
                )))
        }
        guard let first = blocks.first,
              let content = CanonicalDocumentContent(
                  firstBlock: first, remainingBlocks: Array(blocks.dropFirst())
              )
        else
        {
            throw WritingTextFailure.unsupportedDocument
        }
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(UUID()), revision: .zero,
            content: content
        )
        guard let seed = WritingDocumentSeed(document: document),
              let projection = WritingProjection(seed.state),
              projection.text.utf16.elementsEqual(text.utf16)
        else
        {
            throw WritingTextFailure.excessiveText
        }
        state = seed.state
    }
}
