import Testing

@testable import FundamentalDocument

extension DocumentHistorySequenceTests
{
    func runUnits(
        _ content: CanonicalDocumentContent
    ) throws -> [[[UInt16]]]
    {
        try content.blocks.map
        {
            let block = try #require(EditableSemanticBlock($0.block))
            return block.runs.map { Array($0.text.utf16) }
        }
    }
}
