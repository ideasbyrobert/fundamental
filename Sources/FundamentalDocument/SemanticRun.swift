struct SemanticRun: Codable, Equatable, Sendable
{
    var text: String
    var traits: Set<SemanticInlineTrait>
    var link: String?
    var language: String?

    init(
        text: String,
        traits: Set<SemanticInlineTrait> = [],
        link: String? = nil,
        language: String? = nil
    )
    {
        self.text = text
        self.traits = traits
        self.link = link
        self.language = language
    }

    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(
            keyedBy: SemanticRunCodingKey.self
        )
        text = try container.decode(String.self, forKey: .text)
        traits = Set(
            try container.decode(
                [SemanticInlineTrait].self,
                forKey: .traits
            )
        )
        link = try container.decodeIfPresent(String.self, forKey: .link)
        language = try container.decodeIfPresent(
            String.self,
            forKey: .language
        )
    }

    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(
            keyedBy: SemanticRunCodingKey.self
        )
        try container.encode(text, forKey: .text)
        try container.encode(
            traits.sorted { $0.rawValue < $1.rawValue },
            forKey: .traits
        )
        try container.encodeIfPresent(link, forKey: .link)
        try container.encodeIfPresent(language, forKey: .language)
    }
}
