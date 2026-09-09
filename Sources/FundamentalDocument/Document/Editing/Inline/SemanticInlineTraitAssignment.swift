package struct SemanticInlineTraitAssignment: Equatable, Sendable
{
    let trait: SemanticInlineTrait
    let enabled: Bool

    package init(trait: SemanticInlineTrait, enabled: Bool)
    {
        self.trait = trait
        self.enabled = enabled
    }

    func applying(to attributes: SemanticRunAttributes) -> SemanticRunAttributes
    {
        switch attributes
        {
        case let .direct(traits):
            return .direct(traits: applying(to: traits))
        case let .scoped(traits, scopes):
            return .scoped(traits: applying(to: traits), scopes: scopes)
        }
    }

    private func applying(
        to original: Set<SemanticInlineTrait>
    ) -> Set<SemanticInlineTrait>
    {
        var traits = original
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
        return traits
    }
}
