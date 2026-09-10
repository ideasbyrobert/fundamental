import FundamentalMacOracle
import Testing

@testable import FundamentalPresentation

extension MacReaderDocumentFixture
{
    static func mouseSite(
        _ site: PresentedCaretSite, line: PresentedTextLine
    ) throws -> PresentedCaretSite
    {
        let y = line.lineBounds.minY + line.lineBounds.size.height * 0.5
        return PresentedCaretSite(
            utf16Offset: site.utf16Offset,
            position: try #require(PresentationPoint(x: site.position.x, y: y)),
            sourcePoint: site.sourcePoint
        )
    }

    static func selectionDiagnostic(
        _ lines: [PresentedTextLine], model: MacReaderModel
    ) -> String
    {
        lines.map
        {
            line in
            let carets = line.caretSites.map
            {
                site in
                let offset = site.sourcePoint.utf16Offset
                let hit = model.nearestPosition(to: site.position)?
                    .sourcePoint.utf16Offset
                return "\(offset):\(site.position.x),\(site.position.y)"
                    + " hit:\(String(describing: hit))"
            }.joined(separator: "; ")
            return "\(line.text.debugDescription) \(line.lineBounds) "
                + "\(line.selectionExtent) [\(carets)]"
        }.joined(separator: " | ")
    }
}
