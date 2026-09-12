import Foundation
import FundamentalDocument

struct WritingFindReplacement
{
    let command: DocumentSessionCommand

    init?(
        _ results: WritingFindResults, ranges: [NSRange], text: String,
        in projection: WritingProjection
    )
    {
        let matches = Set(results.ranges)
        guard results.observation == projection.observation, !ranges.isEmpty,
              ranges.allSatisfy(matches.contains),
              text.utf16.count <= WritingSurfacePolicy.maximumUTF16Units,
              WritingFindQuery.isSingleLine(text)
        else
        {
            return nil
        }
        var values: [SemanticTextSubstitution] = []
        for native in ranges
        {
            guard let range = projection.range(native),
                  let attributes = projection.snapshot.typingAttributes(
                      in: range
                  ),
                  let value = SemanticTextSubstitution(
                      range: range, text: text, attributes: attributes
                  )
            else
            {
                return nil
            }
            values.append(value)
        }
        guard let batch = SemanticTextBatchReplacement(values)
        else
        {
            return nil
        }
        let command = DocumentSessionCommand.replace(results.observation, batch)
        switch DocumentSessionTransition(command, in: .editable(
            projection.snapshot
        ))
        {
        case let .applied(state):
            guard WritingProjection(state) != nil
            else
            {
                return nil
            }
        case .unchanged:
            break
        case .refused:
            return nil
        }
        self.command = command
    }
}
