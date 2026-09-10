import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@MainActor
@Suite("Native selection extents")
struct LayoutSelectionExtentTests
{
    @Test("native direction and translation preserve selection edges",
          arguments: ["A\n", "אב\n", "אב AB\n"], [240.0, 480.0])
    func direction(text: String, width: Double) throws
    {
        let native = NativeTextKit2Layout()
        let snapshot = try native.layout(
            LayoutFixture.projection([
                .paragraph(SemanticParagraph(runs: [
                    LayoutFixture.direct(text)
                ]))
            ]), request: LayoutFixture.request(width: width)
        )
        guard case let .lines(fragment) = snapshot.firstFragment
        else
        {
            Issue.record("Expected a native text line")
            return
        }
        let line = fragment.line
        let rtl = text.hasPrefix("אב")
        #expect(line.selectionExtent.leading == (rtl ? width : 0))
        #expect(line.selectionExtent.trailing == (rtl ? 0 : width))
        let moved = try native.translated(line, dx: 19.25, dy: 37.5)
        #expect(moved.selectionExtent.leading
            == line.selectionExtent.leading + 19.25)
        #expect(moved.selectionExtent.trailing
            == line.selectionExtent.trailing + 19.25)
        #expect(moved.text.utf16.elementsEqual(text.utf16))
        #expect(moved.sourceSlices == line.sourceSlices)
    }

    @Test("empty list lines retain their inner container edges",
          arguments: SemanticListKind.allCases)
    func listIndent(kind: SemanticListKind) throws
    {
        let lines = try LayoutListLineFixture.lines(
            kind, runs: [LayoutFixture.direct("\n")], width: 240
        )
        let first = try #require(lines.first)
        let marker = try #require(first.marker)
        #expect(first.selectionExtent.minX > 0)
        #expect(marker.inkBounds.maxX <= first.selectionExtent.minX)
        #expect(lines.allSatisfy
        {
            $0.selectionExtent == first.selectionExtent
        })
        #expect(first.selectionExtent.maxX == 240)
    }

    @Test("nonfinite selection edges and translation overflow refuse")
    func nonfinite() throws
    {
        for value in [Double.infinity, -.infinity, .nan]
        {
            #expect(LayoutSelectionExtent(leading: value, trailing: 0) == nil)
            #expect(LayoutSelectionExtent(leading: 0, trailing: value) == nil)
        }
        let maximum = Double.greatestFiniteMagnitude
        #expect(LayoutSelectionExtent(leading: -maximum, trailing: maximum)
            == nil)
        let extent = try #require(LayoutSelectionExtent(
            leading: 0, trailing: maximum
        ))
        #expect(throws: LayoutFailure.nonfiniteNativeGeometry)
        {
            try NativeTextKit2Layout().translated(extent, dx: maximum)
        }
    }
}
