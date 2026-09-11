package struct ParagraphBreak: Sendable
{
    package let position: Int
    package let visibleEnd: Int
    package let kind: ParagraphBreakKind

    package var terminal: Bool
    {
        if case .terminal = kind
        {
            return true
        }
        return false
    }

    package var hyphenated: Bool
    {
        switch kind
        {
        case .authored, .automatic: true
        default: false
        }
    }

    package var penalty: Double
    {
        switch kind
        {
        case .authored(_, conditional: true): 100
        case .automatic: 2500
        default: 0
        }
    }

    package var emergency: Int
    {
        if case .emergency = kind
        {
            return 1
        }
        return 0
    }
}
