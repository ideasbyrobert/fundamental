package enum PatternLanguage: String, CaseIterable, Sendable
{
    case american = "en_US"
    case british = "en_GB"
    case russian = "ru_RU"

    package func accepts(_ text: String) -> Bool
    {
        !text.isEmpty && text.unicodeScalars.allSatisfy
        {
            switch self
            {
            case .american, .british:
                (97...122).contains($0.value)
            case .russian:
                (1072...1103).contains($0.value) || $0.value == 1105
            }
        }
    }
}
