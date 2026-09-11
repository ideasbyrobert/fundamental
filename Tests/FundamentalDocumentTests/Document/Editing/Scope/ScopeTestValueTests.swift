import Testing

@Suite("Scope fixture validation")
struct ScopeTestValueTests
{
    @Test("validated fixture values retain exact source spelling",
          arguments: [" ru-RU ", " e\u{301} ", " Язык\n"])
    func spelling(_ text: String) throws
    {
        let link = try ScopeTestValue.link(text)
        let language = try ScopeTestValue.language(text)
        #expect(Array(link.value.utf8) == Array(text.utf8))
        #expect(Array(language.value.utf8) == Array(text.utf8))
    }

    @Test("invalid fixture values cannot become scope-removal commands",
          arguments: ["", " ", "\t\r\n"])
    func refusal(_ text: String) throws
    {
        try refuses
        {
            _ = try ScopeTestValue.link(text)
        }
        try refuses
        {
            _ = try ScopeTestValue.language(text)
        }
    }

    private func refuses(_ construct: () throws -> Void) throws
    {
        var returned = false
        try withKnownIssue("Fixture validation must reject invalid input.")
        {
            try construct()
            returned = true
        } matching:
        {
            if case .expectationFailed = $0.kind
            {
                return true
            }
            return false
        }
        #expect(!returned)
    }
}
