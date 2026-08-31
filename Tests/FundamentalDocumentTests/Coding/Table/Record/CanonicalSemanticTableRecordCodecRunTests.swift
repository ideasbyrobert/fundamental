import Testing

@testable import FundamentalDocument

extension CanonicalSemanticTableRecordCodecTests
{
    static func runRoot(
        _ runs: String
    ) -> String
    {
        let cell =
            #"{"alignment":"leading","kind":"regular","runs":[\#(runs)]}"#
        return cellRoot(cell)
    }

    static func invalidEvidenceCases() -> [String]
    {
        let table = #"{"kind":"table"}"#
        let row = #"{"kind":"row","row":-1}"#
        let validRow = #"{"kind":"row","row":0}"#
        let cell = #"{"cell":0,"kind":"cell","row":2}"#
        let validCell = #"{"cell":0,"kind":"cell","row":0}"#
        return [
            #"{"confidence":2,"kind":"confidence","target":{"kind":"table"}}"#,
            fact(#""confidence":true,"kind":"confidence""#, target: table),
            fact(#""kind":"future""#, target: table),
            fact(#""confidence":1,"kind":"confidence""#,
                 target: #"{"kind":"future"}"#),
            fact(#""confidence":1,"kind":"confidence""#,
                 target: validRow),
            fact(#""kind":"sourceLocation","location":" ""#,
                 target: table),
            fact(#""kind":"sourceLocation","location":"row""#,
                 target: row),
            fact(#""confidence":1,"kind":"confidence""#, target: cell),
            fact(
                #""kind":"repair","repair":"headerRowCountClamped""#,
                target: validCell)
        ]
    }

    @Test("direct and every admitted scoped run decode exact facts")
    func directAndEveryAdmittedScopedRunDecodeExactFacts() throws
    {
        let direct = #"{"text":"D","traits":["strong","emphasis"]}"#
        let link = #"{"link":"page/one","text":"L","traits":[]}"#
        let language =
            #"{"language":"hy","text":"G","traits":[]}"#
        let both =
            #"{"language":"en","link":"page/two","text":"B","traits":[]}"#
        let json = #"\#(direct),\#(link),\#(language),\#(both)"#
        let runs = try Self.decode(Self.runRoot(json))
            .table.content.bodyRows[0].cells[0].runs

        guard case .direct = runs[0],
              case let .scoped(linkRun) = runs[1],
              case let .scoped(languageRun) = runs[2],
              case let .scoped(bothRun) = runs[3]
        else
        {
            Issue.record("Expected direct and all scoped run forms")
            return
        }
        #expect(runs[0].traits == [.strong, .emphasis])
        #expect(linkRun.scopes == .link(try #require(
            SemanticLinkDestination("page/one")
        )))
        #expect(languageRun.scopes == .language(try #require(
            SemanticLanguageIdentifier("hy")
        )))
        #expect(bothRun.scopes == .linkAndLanguage(
            link: try #require(SemanticLinkDestination("page/two")),
            language: try #require(SemanticLanguageIdentifier("en"))
        ))
    }

    @Test("invalid scopes traits and required run facts refuse")
    func invalidScopesTraitsAndRequiredRunFactsRefuse()
    {
        let cases = [
            #"{"link":null,"text":"A","traits":[]}"#,
            #"{"link":"   ","text":"A","traits":[]}"#,
            #"{"language":"","text":"A","traits":[]}"#,
            #"{"text":"A","traits":["strong","strong"]}"#,
            #"{"text":"A","traits":["future"]}"#,
            #"{"text":1,"traits":[]}"#,
            #"{"text":"A","traits":null}"#,
            #"{"traits":[]}"#,
            #"{"text":"A"}"#
        ]

        for run in cases
        {
            Self.expectRefusal(Self.runRoot(run))
        }
    }
}
