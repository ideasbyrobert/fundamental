import Testing

@testable import FundamentalPresentation

extension PresentationFixture
{
    static func textResidents(
        _ snapshot: PresentationSnapshot
    ) -> [(PresentedResident, PresentedTextLine)]
    {
        snapshot.presentedDocument.residents.all.compactMap
        {
            guard let line = PresentationComposer.residentText($0.content)
            else
            {
                return nil
            }
            return ($0, line)
        }
    }

    static func position(
        _ resident: PresentedResident,
        line: PresentedTextLine,
        caret: Int
    ) throws -> PresentationTextPosition
    {
        let site = try #require(line.caretSites.indices.contains(caret)
            ? line.caretSites[caret]
            : nil)
        return PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: site.sourcePoint
        )
    }
}
