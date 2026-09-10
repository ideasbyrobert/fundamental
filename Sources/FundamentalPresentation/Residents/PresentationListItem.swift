package struct PresentationListItem: Equatable, Sendable
{
    package let kind: PresentationListKind
    package let position: PresentationListPosition

    package var label: String
    {
        switch kind
        {
        case .bulleted:
            "•"
        case .numbered:
            "\(position.number)."
        }
    }
}
