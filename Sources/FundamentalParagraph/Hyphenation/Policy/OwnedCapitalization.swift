package enum OwnedCapitalization: String, Sendable
{
    case lowercase
    case initialCapital
    case allCapitals
    case mixed
    case uncased

    package init(_ text: String)
    {
        let letters = text.unicodeScalars.filter { $0.properties.isCased }
        if letters.isEmpty
        {
            self = .uncased
        }
        else if letters.allSatisfy({ $0.properties.isLowercase })
        {
            self = .lowercase
        }
        else if letters.allSatisfy({ $0.properties.isUppercase })
        {
            self = .allCapitals
        }
        else if letters.first?.properties.isUppercase == true
            && letters.dropFirst().allSatisfy({ $0.properties.isLowercase })
        {
            self = .initialCapital
        }
        else
        {
            self = .mixed
        }
    }

    package var permitsLookup: Bool
    {
        self == .lowercase || self == .initialCapital
    }
}
