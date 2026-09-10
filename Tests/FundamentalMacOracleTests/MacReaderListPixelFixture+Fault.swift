import Testing

@testable import FundamentalPresentation

extension MacReaderListPixelFixture
{
    static func corrupt(
        _ snapshot: PresentationSnapshot, fault: MacReaderListAdmissionFault
    ) throws -> PresentationSnapshot
    {
        let residents = snapshot.presentedDocument.residents.all
        let resident = try #require(residents.first)
        let line = try #require(resident.content.textLine)
        let original = try #require(resident.content.listMarker)
        let batch = try #require(snapshot.presentedDocument.marks.compactMap
        {
            mark -> PresentationGlyphBatch? in
            guard case let .glyphs(batch) = mark,
                  case .listMarker = batch.source
            else { return nil }
            return batch
        }.first)
        var marker: PresentationListMarker? = original
        var generated = original.source
        var position: PresentationPoint?
        var slices: [PresentationSourceSlice]?
        switch fault
        {
        case .missingMarker, .ordinaryContent:
            marker = nil
        case .noninitialMarker, .duplicateResident:
            break
        case .foreignOwner, .wrongKind, .wrongIndex, .wrongCount:
            let item = PresentationListItem(
                kind: fault == .wrongKind ? .bulleted : .numbered,
                position: try #require(PresentationListPosition(
                    index: fault == .wrongIndex ? 1 : 0,
                    count: fault == .wrongCount ? 3 : 2
                ))
            )
            let owner = fault == .foreignOwner
                ? residents[1].residentID : resident.residentID
            let source = try #require(PresentationListMarkerSource(
                residentID: owner, item: item
            ))
            marker = try changedMarker(original, source: source)
        case .foreignGlyphs:
            generated = try #require(PresentationListMarkerSource(
                residentID: residents[1].residentID, item: original.source.item
            ))
        case .canonicalGlyphs:
            slices = line.sourceSlices
        case .overflowingOrigin:
            let baseline = try #require(PresentationPoint(
                x: -Double.greatestFiniteMagnitude, y: original.baseline.y
            ))
            marker = try changedMarker(
                original, source: original.source, baseline: baseline
            )
            let location = try #require(PresentationPoint(
                x: Double.greatestFiniteMagnitude,
                y: batch.firstGlyph.position.y
            ))
            position = location
        }
        let glyphs = changedBatch(
            batch, source: .listMarker(generated),
            position: position, slices: slices
        )
        let listLine: PresentedListLine = marker.map { .first($0, line) }
            ?? .continuation(line)
        let ordinary = fault == .ordinaryContent
        let residentID = fault == .noninitialMarker
            ? try #require(PresentationResidentID(
                blockID: resident.residentID.blockID,
                blockOrdinal: resident.residentID.blockOrdinal,
                fragmentOrdinal: 1
            )) : resident.residentID
        let changed = PresentedResident(
            residence: resident.residence,
            storage: PresentedResidentStorage(
                residentID: residentID, frame: resident.frame,
                content: ordinary ? .body(line)
                    : .list(original.source.item, listLine),
                marks: [.glyphs(glyphs)]
            )
        )
        return try MacRasterOriginFixture.snapshot(
            snapshot,
            residents: fault == .duplicateResident
                ? [changed, changed] : [changed],
            marks: [.glyphs(glyphs)]
        )
    }
}
