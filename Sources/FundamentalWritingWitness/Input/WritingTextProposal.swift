import Foundation
import FundamentalDocument

struct WritingTextProposal: Equatable, Sendable
{
    let command: DocumentSessionCommand

    init?(
        ranges: [NSRange],
        replacements: [String]?,
        in projection: WritingProjection
    )
    {
        guard ranges.count == 1,
              let replacements, replacements.count == 1,
              replacements[0].utf16.count <=
                  WritingSurfacePolicy.maximumUTF16Units * 2,
              let context = WritingTextContext(ranges[0], in: projection),
              let attributes = projection.snapshot.typingAttributes(
                  in: context.range
              ) ?? WritingRunSequence(projection)?.partition(ranges[0])?
                  .selected.first(where: { !$0.text.isEmpty })?.attributes
        else
        {
            return nil
        }
        let range = context.range
        let replacement = context.replacement(replacements[0])
        let structural = context.separators > 0 ||
            (!context.isCode && replacement.contains("\n"))
        let inserted = context.isCode ? 0 : replacement.utf16.reduce(0)
        {
            $0 + ($1 == 0x0A ? 1 : 0)
        }
        let paragraphs = projection.map.spans.count - context.separators +
            inserted
        guard paragraphs <= WritingSurfacePolicy.maximumParagraphs
        else
        {
            return nil
        }
        let edit: CanonicalDocumentEdit?
        if structural
        {
            edit = Self.paragraphEdit(replacement, in: range,
                                      sourceLines: context.isCode,
                                      attributes: attributes)
        }
        else
        {
            guard Self.admitsCount(
                replacing: ranges[0], with: replacement,
                context: context, in: projection
            )
            else
            {
                return nil
            }
            edit = Self.textEdit(replacement, in: range, attributes: attributes)
        }
        guard let edit
        else
        {
            return nil
        }
        let command = DocumentSessionCommand.edit(projection.observation, edit)
        guard !structural || Self.admits(command, in: projection)
        else
        {
            return nil
        }
        self.command = command
    }
}
