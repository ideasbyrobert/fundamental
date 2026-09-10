extension WritingScopeKind
{
    var title: String
    {
        switch self
        {
        case .link: "Link"
        case .language: "Text Language"
        }
    }

    var placeholder: String
    {
        switch self
        {
        case .link: "e.g. https://example.com"
        case .language: "e.g. en or ru"
        }
    }

    var removalTitle: String
    {
        switch self
        {
        case .link: "Remove Link"
        case .language: "Remove Language"
        }
    }
}
