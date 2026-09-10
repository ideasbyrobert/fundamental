import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderListTests
{
    @Test("newline-only selection publishes visible source feedback",
          arguments: SemanticListKind.allCases)
    func newlineOnlySelection(kind: SemanticListKind) throws
    {
        for block in [
            MacReaderDocumentFixture.paragraph("\n"),
            MacReaderListFixture.block(kind, "\n")
        ]
        {
            let source = try MacReaderDocumentFixture.source([block])
            let model = try MacReaderDocumentFixture.model(source)
            let snapshot = model.snapshot
            let resident = snapshot.presentedDocument.residents.first
            let line = try #require(resident.content.textLine)
            let first = try #require(line.caretSites.first)
            let last = try #require(line.caretSites.last)
            #expect(line.text == "\n")
            #expect(first.sourcePoint.utf16Offset == 0)
            #expect(last.sourcePoint.utf16Offset == 1)
            #expect(model.showSelection(
                anchor: PresentationTextPosition(
                    residentID: resident.residentID,
                    sourcePoint: first.sourcePoint
                ),
                focus: PresentationTextPosition(
                    residentID: resident.residentID,
                    sourcePoint: last.sourcePoint
                )
            ))
            guard case let .selection(document, selection) = model.snapshot
            else
            {
                Issue.record("Expected visible line-break selection")
                return
            }
            #expect(document.sharesStorage(with: snapshot.presentedDocument))
            #expect(selection.text == "\n")
            #expect(selection.firstFragment.logicalBounds.size.width > 0)
        }
    }
}
