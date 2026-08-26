enum BlockKeyword
{
    static let all =
    [
        "func", "struct", "enum", "class", "actor", "protocol",
        "extension", "init", "deinit", "subscript", "if", "else",
        "for", "while", "guard", "switch", "do", "catch", "repeat",
        "var", "let"
    ]

    static let modifiers =
    [
        "public ", "private ", "internal ", "fileprivate ", "package ",
        "open ", "static ", "final ", "mutating ", "nonmutating ",
        "override ", "required ", "convenience ", "lazy ", "weak ",
        "unowned ", "indirect ", "nonisolated ",
        "@discardableResult ", "@inlinable ", "@main ", "@objc ",
        "@testable "
    ]

    static func opens(_ code: String) -> Bool
    {
        let body = stripped(code)
        return all.contains { begins(body, with: $0) }
    }

    static func stripped(_ code: String) -> String
    {
        var body = Substring(code.drop { $0 == " " })
        var found = true
        while found
        {
            found = false
            for modifier in modifiers where body.hasPrefix(modifier)
            {
                body = body.dropFirst(modifier.count)
                body = body.drop { $0 == " " }
                found = true
            }
        }
        return String(body)
    }

    private static func begins(
        _ body: String,
        with keyword: String
    ) -> Bool
    {
        guard body.hasPrefix(keyword)
        else
        {
            return false
        }
        let next = body.dropFirst(keyword.count).first
        return next == nil || next == " " || next == "(" || next == "<"
    }
}
