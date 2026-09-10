import Foundation
import FundamentalDocument

struct WritingCompositionInput
{
    let command: DocumentSessionCommand
    let projection: WritingProjection

    init?(
        baseline: WritingProjection, range: NSRange,
        replacement: WritingRunSequence, selection: NSRange,
        attributes: SemanticRunAttributes, unchanged: Bool
    )
    {
        let edit: CanonicalDocumentEdit?
        let destination: WritingProjection
        if unchanged
        {
            edit = nil
            destination = baseline
        }
        else
        {
            guard let proposal = WritingTextProposal(replacement: replacement,
                range: range, in: baseline),
                  case let .edit(_, value) = proposal.command,
                  case let .applied(state) = DocumentSessionTransition(
                      proposal.command, in: .editable(baseline.snapshot)
                  ), let projected = WritingProjection(state)
            else
            {
                return nil
            }
            edit = value
            destination = projected
        }
        guard let completion = Self.complete(selection, in: destination,
            attributes: attributes, previous: baseline.snapshot)
        else
        {
            return nil
        }
        command = .input(baseline.observation, DocumentInputTransaction(
            edit: edit, selection: completion.selection,
            typingIntent: completion.typingIntent
        ))
        let result = DocumentSessionTransition(
            command, in: .editable(baseline.snapshot)
        )
        switch result
        {
        case let .applied(state):
            guard let projected = WritingProjection(state)
            else
            {
                return nil
            }
            projection = projected
        case .unchanged:
            projection = baseline
        case .refused:
            return nil
        }
    }
}
