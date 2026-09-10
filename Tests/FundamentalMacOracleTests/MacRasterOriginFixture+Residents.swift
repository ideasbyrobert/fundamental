import Testing

@testable import FundamentalPresentation

extension MacRasterOriginFixture
{
    static func snapshot(
        _ source: PresentationSnapshot, residents: [PresentedResident],
        marks: [PresentationMark]
    ) throws -> PresentationSnapshot
    {
        let document = source.presentedDocument
        return .document(PresentedDocument(
            lineage: document.lineage,
            storage: PresentedDocumentStorage(
                plane: document.plane,
                sourceAnchor: document.sourceAnchor,
                residents: PresentedResidentCollection(
                    first: try #require(residents.first),
                    remaining: Array(residents.dropFirst())
                ),
                marks: marks
            )
        ))
    }

    static func resident(
        _ source: PresentedResident, content: PresentedResidentContent
    ) -> PresentedResident
    {
        PresentedResident(
            residence: source.residence,
            storage: PresentedResidentStorage(
                residentID: source.residentID,
                frame: source.frame, content: content, marks: source.marks
            )
        )
    }

    static func line(
        _ source: PresentedTextLine, baseline: PresentationPoint,
        empty: Bool = false
    ) -> PresentedTextLine
    {
        PresentedTextLine(
            text: empty ? "" : source.text,
            defaultFont: source.defaultFont, lineBounds: source.lineBounds,
            baseline: baseline,
            sourceSlices: empty ? [] : source.sourceSlices,
            firstCaretSite: source.firstCaretSite,
            remainingCaretSites: empty ? [] : source.remainingCaretSites
        )
    }
}
