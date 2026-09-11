package struct PatternData: Sendable
{
    package let patterns: [WeightedPattern]
    package let exceptions: [PatternException]

    package init(_ source: String) throws(PatternFailure)
    {
        let tokens = Self.tokens(source)
        var cursor = 0
        var patterns: [WeightedPattern] = []
        var exceptions: [PatternException] = []
        var seen: Set<String> = []
        while cursor < tokens.count
        {
            let command = tokens[cursor]
            guard command == "\\patterns" || command == "\\hyphenation",
                  seen.insert(command).inserted,
                  cursor + 1 < tokens.count, tokens[cursor + 1] == "{"
            else
            {
                throw .invalidDocument
            }
            cursor += 2
            while cursor < tokens.count, tokens[cursor] != "}"
            {
                if command == "\\patterns"
                {
                    patterns.append(try WeightedPattern(tokens[cursor]))
                }
                else
                {
                    exceptions.append(try PatternException(tokens[cursor]))
                }
                cursor += 1
            }
            guard cursor < tokens.count, tokens[cursor] == "}"
            else
            {
                throw .invalidDocument
            }
            cursor += 1
        }
        guard seen.contains("\\patterns")
        else
        {
            throw .invalidDocument
        }
        self.patterns = patterns
        self.exceptions = exceptions
    }

    private static func tokens(_ source: String) -> [String]
    {
        let text = source.split(
            separator: "\n", omittingEmptySubsequences: false
        ).map { $0.prefix(while: { $0 != "%" }) }.joined(separator: "\n")
        var result: [String] = []
        var token = ""
        for character in text
        {
            if character.isWhitespace || character == "{" || character == "}"
            {
                if !token.isEmpty
                {
                    result.append(token)
                    token = ""
                }
                if character == "{" || character == "}"
                {
                    result.append(String(character))
                }
            }
            else
            {
                token.append(character)
            }
        }
        if !token.isEmpty
        {
            result.append(token)
        }
        return result
    }
}
