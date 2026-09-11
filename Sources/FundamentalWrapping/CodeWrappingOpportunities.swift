package struct CodeWrappingOpportunities: Sendable
{
    package let priorities: [Int: CodeWrappingPriority]

    package init(_ source: WrappingSource)
    {
        var result: [Int: CodeWrappingPriority] = [:]
        var scanner = CodeWrappingScanner()
        var iterator = source.text.makeIterator()
        var current = iterator.next()
        var offset = 0
        while let character = current
        {
            let next = iterator.next()
            offset += character.utf16.count
            if let priority = scanner.priority(after: character, before: next)
            {
                result[offset] = priority
            }
            current = next
        }
        priorities = result
    }
}
