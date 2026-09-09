package struct SemanticInlineTraitChange: Equatable, Sendable
{
    let range: DocumentRange
    let trait: SemanticInlineTrait
    let enabled: Bool

    package init(
        range: DocumentRange, trait: SemanticInlineTrait, enabled: Bool
    )
    {
        self.range = range
        self.trait = trait
        self.enabled = enabled
    }

    func applying(to run: SemanticRun) -> SemanticRun
    {
        guard !run.text.isEmpty
        else
        {
            return run
        }
        var traits = run.traits
        if enabled
        {
            traits.insert(trait)
            if trait == .superscript
            {
                traits.remove(.subscriptText)
            }
            else if trait == .subscriptText
            {
                traits.remove(.superscript)
            }
        }
        else
        {
            traits.remove(trait)
        }
        switch run
        {
        case .direct:
            return SemanticRun(text: run.text, traits: traits)
        case let .scoped(scoped):
            return SemanticRun(text: run.text, attributes: .scoped(
                traits: traits, scopes: scoped.scopes
            ))
        }
    }
}
