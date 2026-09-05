import Testing

@testable import FundamentalPresentation

extension MacColorPoison
{
    static func background(
        _ snapshot: PresentationSnapshot,
        color: PresentationColor
    ) throws -> PresentationSnapshot
    {
        let palette = try #require(PresentationPalette(
            documentBackground: color,
            tableBackground: color,
            headerBackground: color,
            rule: color,
            text: color,
            decoration: color
        ))
        let document = snapshot.presentedDocument
        let source = document.plane
        let plane = PresentationDocumentPlane(
            documentSize: source.documentSize,
            logicalBounds: source.logicalBounds,
            pixelBounds: source.pixelBounds,
            backingScale: source.backingScale,
            appearance: source.appearance,
            colorSpace: source.colorSpace,
            palette: palette
        )
        return .document(PresentedDocument(
            lineage: document.lineage,
            storage: PresentedDocumentStorage(
                plane: plane,
                sourceAnchor: document.sourceAnchor,
                residents: document.residents,
                marks: document.marks
            )
        ))
    }

    static func fill(
        _ snapshot: PresentationSnapshot,
        color: PresentationColor
    ) throws -> PresentationSnapshot
    {
        var marks = snapshot.presentedDocument.marks
        let index = try #require(marks.firstIndex
        {
            if case .fill = $0
            {
                return true
            }
            return false
        })
        guard case let .fill(source) = marks[index]
        else
        {
            throw MacOracleTestFailure.admission
        }
        marks[index] = .fill(PresentationFill(
            residentID: source.residentID,
            role: source.role,
            logicalBounds: source.logicalBounds,
            pixelBounds: source.pixelBounds,
            color: color,
            sourceSlices: source.sourceSlices
        ))
        return MacRasterSnapshotFixture.replacingMarks(
            in: snapshot,
            with: marks
        )
    }
}
