struct SemanticRun: Equatable, Sendable
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
}
