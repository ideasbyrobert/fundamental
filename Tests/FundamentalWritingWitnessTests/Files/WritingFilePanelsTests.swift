import Testing

@testable import FundamentalWritingWitness

@MainActor
@Suite("Native save names present fun documents")
struct WritingFilePanelsTests
{
    @Test("new and legacy save names propose one fun suffix")
    func suggestedNames()
    {
        let cases: [(String?, String)] = [
            (nil, "Untitled.fun"), ("", "Untitled.fun"),
            ("Draft", "Draft.fun"), ("Draft.fun", "Draft.fun"),
            ("Draft.fundamental", "Draft.fun"), ("Draft.FUN", "Draft.fun"),
            ("Draft.v1", "Draft.v1.fun")
        ]
        for (input, expected) in cases
        {
            #expect(WritingFilePanels.suggestedName(input) == expected)
        }
    }
}
