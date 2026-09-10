enum MacReaderListAdmissionFault: CaseIterable
{
    case missingMarker
    case ordinaryContent
    case noninitialMarker
    case foreignOwner
    case wrongKind
    case wrongIndex
    case wrongCount
    case foreignGlyphs
    case canonicalGlyphs
    case duplicateResident
    case overflowingOrigin
}
