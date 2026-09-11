enum SpellingCharacter
{
    static func belongs(_ character: Character) -> Bool
    {
        character.unicodeScalars.allSatisfy
        {
            WeightedPattern.isLetter($0)
                || $0.properties.numericType != nil
                || HyphenationMark(rawValue: $0.value) != nil
        }
    }

    static func alphabetic(_ text: String) -> Bool
    {
        let hasLetter = text.unicodeScalars.contains
        {
            switch $0.properties.generalCategory
            {
            case .uppercaseLetter, .lowercaseLetter, .titlecaseLetter,
                 .modifierLetter, .otherLetter:
                true
            default:
                false
            }
        }
        return hasLetter
            && text.unicodeScalars.allSatisfy(WeightedPattern.isLetter)
    }
}
