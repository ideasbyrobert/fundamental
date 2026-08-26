struct SourceLine
{
    let number: Int
    let text: String

    private let code: String

    init(number: Int, text: String)
    {
        var literals: [(
            hashes: Int,
            multiline: Bool,
            depth: Int
        )] = []
        var regexHashes: Int?
        let code = Self.withoutLiterals(
            in: text,
            literals: &literals,
            regexHashes: &regexHashes
        )
        self.init(number: number, text: text, code: code)
    }

    private init(number: Int, text: String, code: String)
    {
        self.number = number
        self.text = text
        self.code = code
    }

    var width: Int
    {
        text.count
    }

    var carriesComment: Bool
    {
        !isToolsVersionDirective
            && (code.contains("//") || code.contains("/*"))
    }

    var opensBraceOnSameLine: Bool
    {
        let last = code.reversed().drop(while: { $0.isWhitespace }).first
        guard last == "{"
        else
        {
            return false
        }
        return BlockKeyword.opens(code)
    }

    static func lines(in text: String) -> [SourceLine]
    {
        var literals: [(
            hashes: Int,
            multiline: Bool,
            depth: Int
        )] = []
        var regexHashes: Int?
        return text.components(separatedBy: "\n")
            .enumerated()
            .map
            {
                let text = withoutCarriageReturn($0.element)
                let code = withoutLiterals(
                    in: text,
                    literals: &literals,
                    regexHashes: &regexHashes
                )
                return SourceLine(
                    number: $0.offset + 1,
                    text: text,
                    code: code
                )
            }
    }

    private var isToolsVersionDirective: Bool
    {
        text.drop { $0 == " " }.hasPrefix("// swift-tools-version:")
    }

    private static func withoutLiterals(
        in text: String,
        literals: inout [(
            hashes: Int,
            multiline: Bool,
            depth: Int
        )],
        regexHashes: inout Int?
    ) -> String
    {
        let characters = Array(text)
        var result = ""
        var index = 0
        while index < characters.count
        {
            if regexHashes != nil
            {
                index = advanceInsideRegex(
                    in: characters,
                    at: index,
                    result: &result,
                    regexHashes: &regexHashes
                )
                continue
            }
            if literals.last?.depth == 0
            {
                index = advanceInsideLiteral(
                    in: characters,
                    at: index,
                    literals: &literals
                )
                continue
            }
            if startsComment(in: characters, at: index)
            {
                result.append(contentsOf: characters[index...])
                break
            }
            if let start = extendedRegexStart(
                in: characters,
                at: index
            )
            {
                result.append(contentsOf: characters[index..<start.end])
                regexHashes = start.hashes
                index = start.end
                continue
            }
            if let start = literalStart(
                in: characters,
                at: index
            )
            {
                literals.append((
                    start.hashes,
                    start.multiline,
                    0
                ))
                index = start.end
                continue
            }
            if !literals.isEmpty
            {
                let last = literals.count - 1
                if characters[index] == "("
                {
                    literals[last].depth += 1
                }
                else if characters[index] == ")"
                {
                    literals[last].depth -= 1
                    if literals[last].depth == 0
                    {
                        index += 1
                        continue
                    }
                }
            }
            result.append(characters[index])
            index += 1
        }
        discardSingleLineLiterals(&literals)
        return result
    }

    private static func advanceInsideLiteral(
        in characters: [Character],
        at index: Int,
        literals: inout [(
            hashes: Int,
            multiline: Bool,
            depth: Int
        )]
    ) -> Int
    {
        let literal = literals[literals.count - 1]
        if let end = closingEnd(
            in: characters,
            at: index,
            hashes: literal.hashes,
            multiline: literal.multiline
        )
        {
            literals.removeLast()
            return end
        }
        if let end = interpolationEnd(
            in: characters,
            at: index,
            hashes: literal.hashes
        )
        {
            literals[literals.count - 1].depth = 1
            return end
        }
        if literal.hashes == 0, characters[index] == "\\"
        {
            return min(index + 2, characters.count)
        }
        return index + 1
    }

    private static func startsComment(
        in characters: [Character],
        at index: Int
    ) -> Bool
    {
        guard characters[index] == "/", index + 1 < characters.count
        else
        {
            return false
        }
        return characters[index + 1] == "/"
            || characters[index + 1] == "*"
    }

    private static func literalStart(
        in characters: [Character],
        at index: Int
    ) -> (end: Int, hashes: Int, multiline: Bool)?
    {
        guard characters[index] == "#" || characters[index] == "\""
        else
        {
            return nil
        }
        var quote = index
        while quote < characters.count, characters[quote] == "#"
        {
            quote += 1
        }
        guard quote < characters.count, characters[quote] == "\""
        else
        {
            return nil
        }
        let multiline = hasThreeQuotes(in: characters, at: quote)
        let quoteCount = multiline ? 3 : 1
        return (quote + quoteCount, quote - index, multiline)
    }

    private static func extendedRegexStart(
        in characters: [Character],
        at index: Int
    ) -> (end: Int, hashes: Int)?
    {
        guard characters[index] == "#"
        else
        {
            return nil
        }
        var slash = index
        while slash < characters.count, characters[slash] == "#"
        {
            slash += 1
        }
        guard slash < characters.count, characters[slash] == "/"
        else
        {
            return nil
        }
        let hashes = slash - index
        return (slash + 1, hashes)
    }

    private static func advanceInsideRegex(
        in characters: [Character],
        at index: Int,
        result: inout String,
        regexHashes: inout Int?
    ) -> Int
    {
        guard let hashes = regexHashes
        else
        {
            return index
        }
        if characters[index] == "\\"
        {
            let end = min(index + 2, characters.count)
            result.append(contentsOf: characters[index..<end])
            return end
        }
        if characters[index] == "/",
           hasHashes(
                in: characters,
                after: index,
                count: hashes
           )
        {
            let end = index + hashes + 1
            result.append(contentsOf: characters[index..<end])
            regexHashes = nil
            return end
        }
        result.append(characters[index])
        return index + 1
    }

    private static func hasHashes(
        in characters: [Character],
        after index: Int,
        count: Int
    ) -> Bool
    {
        guard index + count < characters.count
        else
        {
            return false
        }
        for offset in 1...count
        {
            if characters[index + offset] != "#"
            {
                return false
            }
        }
        return true
    }

    private static func closingEnd(
        in characters: [Character],
        at index: Int,
        hashes: Int,
        multiline: Bool
    ) -> Int?
    {
        let quoteCount = multiline ? 3 : 1
        guard index + quoteCount + hashes <= characters.count
        else
        {
            return nil
        }
        for offset in 0..<quoteCount
        {
            if characters[index + offset] != "\""
            {
                return nil
            }
        }
        for offset in 0..<hashes
        {
            if characters[index + quoteCount + offset] != "#"
            {
                return nil
            }
        }
        return index + quoteCount + hashes
    }

    private static func interpolationEnd(
        in characters: [Character],
        at index: Int,
        hashes: Int
    ) -> Int?
    {
        guard characters[index] == "\\"
        else
        {
            return nil
        }
        var cursor = index + 1
        for _ in 0..<hashes
        {
            guard cursor < characters.count,
                  characters[cursor] == "#"
            else
            {
                return nil
            }
            cursor += 1
        }
        guard cursor < characters.count, characters[cursor] == "("
        else
        {
            return nil
        }
        return cursor + 1
    }

    private static func hasThreeQuotes(
        in characters: [Character],
        at index: Int
    ) -> Bool
    {
        guard index + 2 < characters.count
        else
        {
            return false
        }
        return characters[index + 1] == "\""
            && characters[index + 2] == "\""
    }

    private static func discardSingleLineLiterals(
        _ literals: inout [(
            hashes: Int,
            multiline: Bool,
            depth: Int
        )]
    )
    {
        while let literal = literals.last,
              !literal.multiline,
              literal.depth == 0
        {
            literals.removeLast()
        }
    }

    private static func withoutCarriageReturn(_ text: String) -> String
    {
        guard text.last == "\r"
        else
        {
            return text
        }
        return String(text.dropLast())
    }
}
