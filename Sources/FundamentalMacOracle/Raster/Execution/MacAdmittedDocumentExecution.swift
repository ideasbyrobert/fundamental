import CoreGraphics
import FundamentalPresentation

@MainActor
final class MacAdmittedDocumentExecution
{
    let source: PresentedDocument
    let colorSpace: MacAdmittedColorSpace
    let background: MacAdmittedColor
    let logicalBounds: CGRect
    let marks: [MacAdmittedRasterMark]

    init(
        source: PresentedDocument,
        colorSpace: MacAdmittedColorSpace,
        background: MacAdmittedColor,
        logicalBounds: CGRect,
        marks: [MacAdmittedRasterMark]
    )
    {
        self.source = source
        self.colorSpace = colorSpace
        self.background = background
        self.logicalBounds = logicalBounds
        self.marks = marks
    }
}
