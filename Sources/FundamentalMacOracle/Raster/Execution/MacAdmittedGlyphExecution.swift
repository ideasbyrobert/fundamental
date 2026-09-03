import CoreGraphics
import FundamentalPresentation

@MainActor
struct MacAdmittedGlyphExecution
{
    let residentID: PresentationResidentID
    let font: MacAdmittedFont
    let color: MacAdmittedColor
    let glyphs: [CGGlyph]
    let positions: [CGPoint]
    let clipBounds: CGRect
}
