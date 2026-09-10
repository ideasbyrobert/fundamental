import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

enum LayoutListLineFixture
{
    static func item(
        _ kind: SemanticListKind,
        number: Int = 1,
        count: Int = 1,
        runs: [SemanticRun]
    ) throws -> (block: ProjectedBlockSource, prose: ProjectedProse)
    {
        let projection = try LayoutFixture.projection([
            .listItem(SemanticListItem(kind: kind, runs: runs))
        ])
        guard case let .prose(block, prose) = projection.firstBlock
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let position = try #require(ProjectedListPosition(
            index: number - 1, count: count
        ))
        return (block, ProjectedProse(
            role: kind == .numbered ? .numbered(position) : .bulleted(position),
            runs: prose.runs
        ))
    }

    @MainActor
    static func lines(
        _ kind: SemanticListKind,
        number: Int = 1,
        count: Int = 1,
        runs: [SemanticRun],
        width: Double = 180,
        originY: Double = 0
    ) throws -> [LayoutLine]
    {
        let item = try item(kind, number: number, count: count, runs: runs)
        return try NativeTextKit2Layout().proseLines(
            item.prose, source: item.block, width: width, originY: originY
        )
    }

    static func expectSource(
        _ lines: [LayoutLine],
        text: String,
        block: ProjectedBlockSource
    )
    {
        #expect(lines.map(\.text).joined() == text)
        #expect(lines.flatMap(\.sourceSlices).map(\.text).joined() == text)
        var base = 0
        for line in lines
        {
            #expect(line.firstCaretStop.utf16Offset == 0)
            #expect(line.caretStops.last?.utf16Offset == line.text.utf16.count)
            for stop in line.caretStops
            {
                #expect(stop.sourcePoint == .block(
                    blockID: block.blockID, utf16Offset: base + stop.utf16Offset
                ))
            }
            base += line.text.utf16.count
        }
        #expect(base == text.utf16.count)
    }
}
