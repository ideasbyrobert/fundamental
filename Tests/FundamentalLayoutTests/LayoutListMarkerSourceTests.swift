import Testing

@testable import FundamentalLayout
@testable import FundamentalProjection

@Suite("Generated list marker source")
struct LayoutListMarkerSourceTests
{
    @Test("only list roles admit marker provenance")
    func admission() throws
    {
        let block = ProjectedBlockSource(
            blockID: LayoutFixture.blockID(7), ordinal: 7
        )
        let refused: [ProjectedProseRole] = [
            .body, .title, .section(.one), .section(.two),
            .section(.three), .section(.four), .section(.five), .section(.six)
        ]
        for role in refused
        {
            #expect(LayoutListMarkerSource(block: block, role: role) == nil)
        }
        let position = try #require(ProjectedListPosition(
            index: 99, count: 100
        ))
        let admitted: [ProjectedProseRole] = [
            .bulleted(position), .numbered(position)
        ]
        for role in admitted
        {
            let marker = try #require(LayoutListMarkerSource(
                block: block, role: role
            ))
            #expect(marker.block == block)
            #expect(marker.role == role)
            #expect(marker.position == position)
        }
    }

    @Test("labels preserve one-based decimal and integer-edge spelling")
    func labels() throws
    {
        let block = ProjectedBlockSource(
            blockID: LayoutFixture.blockID(0), ordinal: 0
        )
        let cases: [(Int, String)] = [
            (1, "1."), (9, "9."), (10, "10."), (99, "99."),
            (100, "100."), (1000, "1000."),
            (Int.max, "9223372036854775807.")
        ]
        for (number, label) in cases
        {
            let position = try #require(ProjectedListPosition(
                index: number - 1, count: number
            ))
            let marker = try #require(LayoutListMarkerSource(
                block: block, role: .numbered(position)
            ))
            #expect(marker.label == label)
            let bullet = try #require(LayoutListMarkerSource(
                block: block, role: .bulleted(position)
            ))
            #expect(Array(bullet.label.utf16) == [0x2022])
        }
    }
}
