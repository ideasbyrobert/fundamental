import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Native projected text layout")
struct LayoutWidthAndSourceTests
{
    @MainActor
    @Test("width changes lines without changing spelling or source")
    func widthAndSource() throws
    {
        let first = "A😀 office "
        let second = "אבג carries exact source through every native line."
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(
                first,
                traits: [.underline, .strong]
            ),
            try LayoutFixture.scoped(second)
        ]))
        let projection = try LayoutFixture.projection([block])
        let mechanism = NativeTextKit2Layout()
        let narrow = try mechanism.layout(
            projection,
            request: LayoutFixture.request(width: 90)
        )
        let wide = try mechanism.layout(
            projection,
            request: LayoutFixture.request(width: 2_000)
        )
        let narrowLines = lineFragments(narrow).map(\.line)
        let wideLines = lineFragments(wide).map(\.line)
        #expect(narrowLines.count > wideLines.count)
        #expect(narrowLines.map(\.text).joined() == first + second)
        #expect(wideLines.map(\.text).joined() == first + second)
        var sourceOffset = 0
        for line in narrowLines
        {
            #expect(line.sourceSlices.map(\.text).joined() == line.text)
            for slice in line.sourceSlices
            {
                #expect(slice.range.count == slice.text.utf16.count)
            }
            #expect(line.caretStops.map(\.utf16Offset)
                == characterBoundaries(line.text))
            #expect(line.firstCaretStop.sourcePoint == .block(
                blockID: LayoutFixture.blockID(0),
                utf16Offset: sourceOffset
            ))
            sourceOffset += line.text.utf16.count
            #expect(line.caretStops.last?.sourcePoint == .block(
                blockID: LayoutFixture.blockID(0),
                utf16Offset: sourceOffset
            ))
        }
        #expect(narrow.lineage.projection == projection.lineage)
        #expect(narrow.lineage.generation == 11)
        #expect(narrow.lineage.specification.parameters.width == 90)
        #expect(!narrow.lineage.specification.resolvedFonts.isEmpty)
        #expect(narrow.fragments.map(\.anchor.fragmentOrdinal)
            == Array(narrow.fragments.indices))
        #expect(narrow.firstFragment.anchor == wide.firstFragment.anchor)
        let decorations = narrowLines.flatMap(\.glyphRuns)
            .flatMap(\.decorations)
        #expect(decorations.contains { $0.kind == .underline })
        #expect(decorations.allSatisfy { !$0.sourceSlices.isEmpty })
    }

    func lineFragments(
        _ snapshot: LayoutSnapshot
    ) -> [LayoutLineFragment]
    {
        snapshot.fragments.compactMap
        {
            guard case let .lines(fragment) = $0
            else
            {
                return nil
            }
            return fragment
        }
    }

    func characterBoundaries(_ text: String) -> [Int]
    {
        var result = [0]
        var offset = 0
        for character in text
        {
            offset += String(character).utf16.count
            result.append(offset)
        }
        return result
    }
}
