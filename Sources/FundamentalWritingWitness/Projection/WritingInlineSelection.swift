import FundamentalDocument

struct WritingInlineSelection: Equatable, Sendable
{
    let values: [Set<SemanticInlineTrait>]

    init?(_ projection: WritingProjection)
    {
        guard let selected = WritingSelectedAttributes(projection)
        else
        {
            return nil
        }
        self.init(selected)
    }

    init(_ selected: WritingSelectedAttributes)
    {
        values = selected.values.map
        {
            switch $0
            {
            case let .direct(traits), let .scoped(traits, _): traits
            }
        }
    }

    func state(of trait: SemanticInlineTrait) -> WritingInlineState
    {
        let count = values.filter { $0.contains(trait) }.count
        return count == 0 ? .off : count == values.count ? .on : .mixed
    }
}
