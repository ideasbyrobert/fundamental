import Testing

@testable import FundamentalPresentation

enum MacColorPoison: CaseIterable
{
    case background
    case fill
    case glyph
    case caret
    case selection

    func applying(
        to snapshot: PresentationSnapshot
    ) throws -> PresentationSnapshot
    {
        let color = try #require(
            MacRasterSnapshotFixture.mismatchedColor(in: snapshot)
        )
        switch self
        {
        case .background:
            return try Self.background(snapshot, color: color)
        case .fill:
            return try Self.fill(snapshot, color: color)
        case .glyph:
            return try #require(
                MacRasterSnapshotFixture.replacingFirstGlyphBatch(
                    in: snapshot,
                    transform:
                    {
                        MacRasterSnapshotFixture.glyphBatch($0, color: color)
                    }
                )
            )
        case .caret:
            return try #require(MacRasterSnapshotFixture.replacingCaretColor(
                in: snapshot,
                with: color
            ))
        case .selection:
            return try #require(
                MacRasterSnapshotFixture.replacingSelectionColor(
                    in: snapshot,
                    with: color
                )
            )
        }
    }
}
