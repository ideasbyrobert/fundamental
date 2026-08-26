import Testing

@testable import lint

@Suite("Words that open a block")
struct BlockKeywordTests
{
    @Test("the standard names the complete keyword vocabulary")
    func vocabularyIsExact()
    {
        #expect(BlockKeyword.all == [
            "func", "struct", "enum", "class", "actor", "protocol",
            "extension", "init", "deinit", "subscript", "if", "else",
            "for", "while", "guard", "switch", "do", "catch", "repeat",
            "var", "let"
        ])
        #expect(BlockKeyword.modifiers == [
            "public ", "private ", "internal ", "fileprivate ", "package ",
            "open ", "static ", "final ", "mutating ", "nonmutating ",
            "override ", "required ", "convenience ", "lazy ", "weak ",
            "unowned ", "indirect ", "nonisolated ",
            "@discardableResult ", "@inlinable ", "@main ", "@objc ",
            "@testable "
        ])
    }

    @Test("every named keyword opens a block")
    func everyKeywordIsRecognized()
    {
        for keyword in BlockKeyword.all
        {
            #expect(BlockKeyword.opens(keyword))
            #expect(BlockKeyword.opens(keyword + " value"))
        }
    }

    @Test("modifiers are stripped before the keyword is read")
    func modifiersAreStripped()
    {
        let source = "  package   static   func perform"
        #expect(BlockKeyword.stripped(source) == "func perform")
        #expect(BlockKeyword.opens("private final class Example"))
        for modifier in BlockKeyword.modifiers
        {
            #expect(BlockKeyword.opens(modifier + "func perform"))
        }
    }

    @Test("a keyword must end where the keyword ends")
    func keywordsAreWholeWords()
    {
        #expect(!BlockKeyword.opens("structure = 1"))
        #expect(BlockKeyword.opens("struct Example"))
        #expect(BlockKeyword.opens("func perform<Value>()"))
        #expect(!BlockKeyword.opens("function perform"))
    }
}
