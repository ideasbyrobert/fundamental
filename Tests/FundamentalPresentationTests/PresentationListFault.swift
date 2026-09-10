enum PresentationListFault: CaseIterable
{
    case missingMarker
    case missingGlyphs
    case ordinaryRole
    case wrongKind
    case wrongIndex
    case wrongCount
    case foreignOwner
    case foreignGlyphSource
    case canonicalMarkerGlyph
}
