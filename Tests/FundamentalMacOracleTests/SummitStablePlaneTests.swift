import FundamentalPresentation
import Testing

extension SummitPublicationTests
{
    @Test("caret and selection reuse the stable document plane")
    func adornmentsReuseStablePlane() throws
    {
        let model = try MacOracleTestSurface.model()
        let document = model.snapshot.presentedDocument
        let resident = try #require(
            document.residents.all.first
            {
                Self.textLine($0.content)?.caretSites.count ?? 0 > 2
            }
        )
        let line = try #require(Self.textLine(resident.content))
        let firstSite = try #require(line.caretSites.first)
        let lastSite = try #require(line.caretSites.last)
        let first = PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: firstSite.sourcePoint
        )
        let last = PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: lastSite.sourcePoint
        )
        #expect(model.showCaret(at: first))
        #expect(model.snapshot.presentedDocument.sharesStorage(
            with: document
        ))
        #expect(model.showSelection(anchor: first, focus: last))
        #expect(model.snapshot.presentedDocument.sharesStorage(
            with: document
        ))
        guard case let .selection(_, selection) = model.snapshot
        else
        {
            Issue.record("The selection was not published")
            return
        }
        #expect(!selection.text.isEmpty)
    }

    private static func textLine(
        _ content: PresentedResidentContent
    ) -> PresentedTextLine?
    {
        switch content
        {
        case let .body(line), let .title(line), let .code(line):
            return line
        case let .section(_, line), let .caption(line):
            return line
        default:
            return nil
        }
    }
}
