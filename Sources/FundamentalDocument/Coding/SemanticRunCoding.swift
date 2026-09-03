extension SemanticRun
{
    package init(from decoder: Decoder) throws
    {
        let container = try decoder.container(
            keyedBy: SemanticRunCodingKey.self
        )
        let text = try container.decode(String.self, forKey: .text)
        let traits = Set(
            try container.decode(
                [SemanticInlineTrait].self,
                forKey: .traits
            )
        )
        let linkValue = try container.decodeIfPresent(
            String.self,
            forKey: .link
        )
        let languageValue = try container.decodeIfPresent(
            String.self,
            forKey: .language
        )
        let link = linkValue.flatMap(SemanticLinkDestination.init)
        let language = languageValue.flatMap(
            SemanticLanguageIdentifier.init
        )

        switch (link, language)
        {
        case (nil, nil):
            self = SemanticRun(text: text, traits: traits)
        case let (.some(link), nil):
            self = .scoped(
                SemanticScopedRun(
                    text: text,
                    traits: traits,
                    scopes: .link(link)
                )
            )
        case let (nil, .some(language)):
            self = .scoped(
                SemanticScopedRun(
                    text: text,
                    traits: traits,
                    scopes: .language(language)
                )
            )
        case let (.some(link), .some(language)):
            self = .scoped(
                SemanticScopedRun(
                    text: text,
                    traits: traits,
                    scopes: .linkAndLanguage(
                        link: link,
                        language: language
                    )
                )
            )
        }
    }

    package func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(
            keyedBy: SemanticRunCodingKey.self
        )
        try container.encode(text, forKey: .text)
        try container.encode(
            traits.sorted { $0.rawValue < $1.rawValue },
            forKey: .traits
        )

        guard case let .scoped(run) = self
        else
        {
            return
        }

        switch run.scopes
        {
        case let .link(link):
            try container.encode(link.value, forKey: .link)
        case let .language(language):
            try container.encode(language.value, forKey: .language)
        case let .linkAndLanguage(link, language):
            try container.encode(link.value, forKey: .link)
            try container.encode(language.value, forKey: .language)
        }
    }
}
