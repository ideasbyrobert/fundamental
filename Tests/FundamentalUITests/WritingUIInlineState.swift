import Foundation

struct WritingUIInlineState
{
    let paragraphs: [[(String, [String])]]

    func matches(_ record: WritingUIRecord) -> Bool
    {
        guard record.format == "fundamental-document",
              record.blocks.count == paragraphs.count
        else
        {
            return false
        }
        return zip(record.blocks, paragraphs).allSatisfy
        {
            block, expected in
            let runs = block.content.runs
            let spelling = runs.flatMap { Array($0.text.utf16) }
            let traits = runs.flatMap
            {
                Array(repeating: $0.traits.sorted(), count: $0.text.utf16.count)
            }
            let expectedSpelling = expected.flatMap { Array($0.0.utf16) }
            let expectedTraits = expected.flatMap
            {
                Array(repeating: $0.1.sorted(), count: $0.0.utf16.count)
            }
            return block.content.kind == "paragraph" &&
                spelling == expectedSpelling && traits == expectedTraits &&
                runs.allSatisfy { $0.language == nil && $0.link == nil }
        }
    }
}
