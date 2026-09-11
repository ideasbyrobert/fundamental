struct CodeWrappingScanner
{
    var quote: Character?
    var escaped = false
    let operators = "=+-*%<>!?&|^~"

    mutating func priority(
        after character: Character, before next: Character?
    ) -> CodeWrappingPriority?
    {
        if WrappingLineEnding(character) != nil
        {
            quote = nil
            escaped = false
            return nil
        }
        if let quote
        {
            if escaped
            {
                escaped = false
                return nil
            }
            if character == "\\"
            {
                escaped = true
                return nil
            }
            if character == quote
            {
                self.quote = nil
                return nil
            }
            return " \t/._".contains(character) ? .secondary : nil
        }
        if "\"'`".contains(character)
        {
            quote = character
            return nil
        }
        if " \t".contains(character)
        {
            return next.map { " \t".contains($0) } == true ? nil : .preferred
        }
        if "()[]{},;:".contains(character)
        {
            return .preferred
        }
        if operators.contains(character)
        {
            return next.map { operators.contains($0) } == true
                ? nil : .preferred
        }
        return "/._".contains(character) ? .secondary : nil
    }
}
