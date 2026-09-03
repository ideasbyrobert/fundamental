import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Native empty table layout")
struct LayoutEmptyTableTests
{
    @MainActor
    @Test("an empty regular table retains structural residency")
    func structuralRegion() throws
    {
        let content = SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        )
        let block = SemanticBlock.table(.semantic(
            .regular(RegularSemanticTable(content: content))
        ))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 320)
        )
        let grid = try #require(snapshot.grids.first)
        #expect(grid.frame.size.height > 0)
        #expect(grid.columnTracks.isEmpty)
        #expect(grid.rowTracks.isEmpty)
        #expect(grid.cells.isEmpty)
        #expect(grid.captionLines.isEmpty)
        #expect(grid.cellLines.isEmpty)
        let query = snapshot.fragments(
            intersecting: grid.frame,
            limit: 1
        )
        #expect(query.fragments.count == 1)
        guard case let .grid(fragment) = snapshot.firstFragment,
              case .region = fragment.content
        else
        {
            Issue.record("Expected one structural grid region")
            return
        }
        #expect(snapshot.lineage.specification.resolvedFonts
            .contains(grid.structuralFont))
    }
}
