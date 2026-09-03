import FundamentalPresentation

@MainActor
enum MacAdmittedRasterMark
{
    case fill(MacAdmittedFillExecution)
    case glyphs(MacAdmittedGlyphExecution)

    var residentID: PresentationResidentID
    {
        switch self
        {
        case let .fill(fill):
            fill.residentID
        case let .glyphs(glyphs):
            glyphs.residentID
        }
    }
}
