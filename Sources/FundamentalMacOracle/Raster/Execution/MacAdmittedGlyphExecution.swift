import CoreGraphics
import FundamentalPresentation

@MainActor
struct MacAdmittedGlyphExecution
{
    let residentID: PresentationResidentID
    let font: MacAdmittedFont
    let color: MacAdmittedColor
    let origin: CGPoint
    let glyphs: [CGGlyph]
    let positions: [CGPoint]
    let clipBounds: CGRect
}
