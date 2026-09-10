import FundamentalDocument

struct WritingScopeSelection: Equatable, Sendable
{
    let kind: WritingScopeKind
    let values: [SemanticRunScopeAssignment]

    init(kind: WritingScopeKind, in selected: WritingSelectedAttributes)
    {
        self.kind = kind
        values = selected.values.map { kind.assignment(in: $0) }
    }

    var uniform: SemanticRunScopeAssignment?
    {
        guard let first = values.first, values.allSatisfy({ $0 == first })
        else
        {
            return nil
        }
        return first
    }

    var value: String { uniform.flatMap { kind.value(of: $0) } ?? "" }
    var isMixed: Bool { uniform == nil }
    var hasScope: Bool { values.contains { kind.value(of: $0) != nil } }

    var state: WritingInlineState
    {
        isMixed ? .mixed : hasScope ? .on : .off
    }
}
