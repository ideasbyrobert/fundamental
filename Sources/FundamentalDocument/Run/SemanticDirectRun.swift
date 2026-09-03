package struct SemanticDirectRun: Equatable, Sendable
{
    package let text: String
    let traits: Set<SemanticInlineTrait>

    init(
        text: String,
        traits: Set<SemanticInlineTrait> = []
    )
    {
        self.text = text
        self.traits = traits
    }
}
