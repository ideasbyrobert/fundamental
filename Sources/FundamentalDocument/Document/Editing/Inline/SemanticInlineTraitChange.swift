package struct SemanticInlineTraitChange: Equatable, Sendable
{
    let range: DocumentRange
    let assignment: SemanticInlineTraitAssignment

    package init(
        range: DocumentRange, trait: SemanticInlineTrait, enabled: Bool
    )
    {
        self.range = range
        assignment = SemanticInlineTraitAssignment(trait: trait,
                                                   enabled: enabled)
    }

    func applying(to run: SemanticRun) -> SemanticRun
    {
        guard !run.text.isEmpty
        else
        {
            return run
        }
        return SemanticRun(text: run.text,
                           attributes: assignment.applying(to: run.attributes))
    }
}
