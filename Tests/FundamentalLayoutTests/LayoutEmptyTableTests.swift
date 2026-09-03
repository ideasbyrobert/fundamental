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
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        ))
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

    @MainActor
    @Test("empty semantic rows retain positive zero-padding tracks")
    func emptyRows() throws
    {
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [
                BodySemanticTableRow(cells: []),
                BodySemanticTableRow(cells: [])
            ],
            columnAlignments: [.leading, .trailing]
        ))
        let block = SemanticBlock.table(.semantic(
            .regular(RegularSemanticTable(content: content))
        ))
        let request = try #require(LayoutRequest(
            generation: 12,
            width: 320,
            blockSpacing: 0,
            rowSpacing: 0,
            columnSpacing: 0,
            cellPadding: 0
        ))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: request
        )
        let grid = try #require(snapshot.grids.first)
        #expect(grid.rowTracks.count == 2)
        #expect(grid.rowTracks.allSatisfy { $0.extent > 0 })
        #expect(grid.frame.size.height
            == grid.rowTracks.reduce(0) { $0 + $1.extent })
        #expect(snapshot.fragments.contains
        {
            guard case let .grid(fragment) = $0,
                  case .rule(.row(1)) = fragment.content
            else
            {
                return false
            }
            return true
        })
    }
}
