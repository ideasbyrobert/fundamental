extension ExplicitParagraphHyphens
{
    package func select(_ index: Int) throws(ExplicitProjectionFailure)
        -> ExplicitBreakSelection
    {
        _ = try opportunity(at: index)
        return ExplicitBreakSelection(owner: identity, index: index)
    }

    package func opportunity(at index: Int) throws(ExplicitProjectionFailure)
        -> ExplicitHyphenOpportunity
    {
        guard records.indices.contains(index)
        else
        {
            throw .invalidSelection(index)
        }
        guard case let .opportunity(value) = records[index].outcome
        else
        {
            throw .refusedSelection(index)
        }
        return value
    }
}
