import Foundation
import FundamentalDocument

struct WritingLinkRequest: Equatable, Sendable
{
    let observation: DocumentObservation
    let selection: NSRange
    let destination: SemanticLinkDestination
    let url: URL

    init?(in projection: WritingProjection)
    {
        guard let destination = projection.selectedLink,
              let url = Self.navigationURL(destination.value)
        else
        {
            return nil
        }
        observation = projection.observation
        selection = projection.selection
        self.destination = destination
        self.url = url
    }

    static func navigationURL(_ spelling: String) -> URL?
    {
        let value = spelling.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.unicodeScalars.contains(where:
            { CharacterSet.controlCharacters.contains($0) }),
              let components = URLComponents(string: value)
        else
        {
            return nil
        }
        switch components.scheme?.lowercased()
        {
        case "http", "https":
            guard components.host?.isEmpty == false
            else
            {
                return nil
            }
        case "mailto":
            guard components.host == nil, !components.path.isEmpty
            else
            {
                return nil
            }
        default:
            return nil
        }
        return components.url
    }
}
