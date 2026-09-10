import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func tablesAndReadOnlyStatesRefuseWithoutFlattening() throws
    {
        let content = try #require(SemanticTableContent(
            headerRows: [], bodyRows: [], columnAlignments: []
        ))
        let table = SemanticBlock.table(.semantic(.regular(
            RegularSemanticTable(content: content)
        )))
        let source = try WritingTestDocument(blocks: [table])
        #expect(WritingProjection(source.state) == nil)
        let readable = try WritingTestDocument("AB").state.snapshot
        #expect(WritingProjection(.readable(readable)) == nil)
    }

    @Test
    func scopesAreNotSilentlyFlattened() throws
    {
        let language = try #require(SemanticLanguageIdentifier("fr"))
        let scoped = try #require(SemanticInsertion(
            text: "X",
            attributes: .scoped(traits: [], scopes: .language(language))
        )).run
        let runs = [scoped]
        for run in runs
        {
            let source = try WritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: [run]))
            ])
            #expect(WritingProjection(source.state) == nil)
        }
    }

    @Test
    func projectionAdmitsExactCapacityAndRefusesOverflow() throws
    {
        let capacity = WritingSurfacePolicy.maximumUTF16Units
        let exact = String(repeating: "😀", count: capacity / 2)
        let projection = try WritingTestDocument(exact).projection()
        #expect(projection.text.utf16.count == capacity)
        let source = try WritingTestDocument(exact + "A")
        #expect(WritingProjection(source.state) == nil)
    }
}
