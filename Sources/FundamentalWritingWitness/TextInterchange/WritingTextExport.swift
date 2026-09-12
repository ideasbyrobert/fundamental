import Foundation
import FundamentalDocument

struct WritingTextExport
{
    static func data(from document: CanonicalDocument) throws -> Data
    {
        let paragraphs = try document.content.blocks.map
        {
            guard let editable = EditableSemanticBlock($0.block)
            else
            {
                throw WritingTextFailure.unsupportedDocument
            }
            return editable.runs.map(\.text).joined()
        }
        return Data(paragraphs.joined(separator: "\n").utf8)
    }
}
