import FundamentalDocument

extension WritingComposition
{
    var presentation: WritingProjection
    {
        guard let proposal,
              case let .applied(state) = DocumentSessionTransition(
                  proposal.command, in: .editable(baseline.snapshot)
              ),
              let preview = WritingProjection(state)
        else
        {
            return baseline
        }
        return preview
    }
}
