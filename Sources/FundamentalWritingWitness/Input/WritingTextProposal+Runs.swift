import Foundation
import FundamentalDocument

extension WritingTextProposal
{
    init?(
        replacement: WritingRunSequence, range: NSRange,
        in projection: WritingProjection
    )
    {
        guard replacement.text.utf16.count <=
            WritingSurfacePolicy.maximumUTF16Units * 2,
              let context = WritingTextContext(range, in: projection)
        else
        {
            return nil
        }
        let paragraphs = WritingParagraphInput(replacement.runs,
            sourceLines: context.isCode).paragraphs
        let count = projection.map.spans.count - context.separators +
            paragraphs.count - 1
        guard count <= WritingSurfacePolicy.maximumParagraphs,
              let edit = SemanticParagraphReplacement(
                  range: context.range, paragraphs: paragraphs,
                  continuationBlockIDs: paragraphs.dropFirst().map
                      { _ in FundamentalBlockID(UUID()) }
              )
        else
        {
            return nil
        }
        let command = DocumentSessionCommand.edit(projection.observation,
                                                  .paragraphs(edit))
        guard Self.admits(command, in: projection)
        else
        {
            return nil
        }
        self.command = command
    }
}
