package struct SemanticRunScopeChange: Equatable, Sendable
{
    let range: DocumentRange
    let assignment: SemanticRunScopeAssignment

    package init(range: DocumentRange, assignment: SemanticRunScopeAssignment)
    {
        self.range = range
        self.assignment = assignment
    }
}
