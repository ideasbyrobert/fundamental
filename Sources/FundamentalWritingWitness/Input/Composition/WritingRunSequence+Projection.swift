import Foundation
import FundamentalDocument

extension WritingRunSequence
{
    init?(_ projection: WritingProjection)
    {
        let blocks = projection.snapshot.snapshot.document.content.blocks
        let spelling = projection.text as NSString
        var runs: [SemanticRun] = []
        for (index, block) in blocks.enumerated()
        {
            guard let editable = EditableSemanticBlock(block.block)
            else
            {
                return nil
            }
            runs += editable.runs
            let span = projection.map.spans[index]
            if span.separatorLength > 0
            {
                let text = spelling.substring(with: NSRange(
                    location: NSMaxRange(span.range),
                    length: span.separatorLength
                ))
                runs.append(SemanticRun(text: text,
                                        attributes: .direct(traits: [])))
            }
        }
        self.init(runs)
        guard text.utf16.elementsEqual(projection.text.utf16)
        else
        {
            return nil
        }
    }
}
