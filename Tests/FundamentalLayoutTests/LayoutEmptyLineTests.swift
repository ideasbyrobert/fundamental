import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Native empty line layout")
struct LayoutEmptyLineTests
{
    @MainActor
    @Test("an empty projected run has one sourceless native line")
    func emptyRun() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct("")
        ]))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 100)
        )
        guard case let .lines(fragment) = snapshot.firstFragment
        else
        {
            Issue.record("Expected a line fragment")
            return
        }
        let line = fragment.line
        #expect(line.text.isEmpty)
        #expect(line.sourceSlices.isEmpty)
        #expect(line.glyphRuns.isEmpty)
        #expect(line.caretStops.map(\.utf16Offset) == [0])
        #expect(line.firstCaretStop.sourcePoint == .block(
            blockID: LayoutFixture.blockID(0),
            utf16Offset: 0
        ))
        #expect(line.frame.size.height > 0)
    }

    @MainActor
    @Test("a trailing newline retains its native empty final line")
    func trailingNewline() throws
    {
        let block = SemanticBlock.code(.plain(PlainSemanticCodeBlock(
            runs: [LayoutFixture.direct("A\n")]
        )))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 100)
        )
        let fragments: [LayoutLineFragment] = snapshot.fragments.compactMap
        {
            guard case let .lines(fragment) = $0
            else
            {
                return nil
            }
            return fragment
        }
        #expect(fragments.map(\.line.text).joined() == "A\n")
        #expect(fragments.last?.line.text == "")
        #expect(fragments.last?.line.sourceSlices == [])
        #expect(fragments.last?.line.firstCaretStop.sourcePoint == .block(
            blockID: LayoutFixture.blockID(0),
            utf16Offset: 2
        ))
        #expect(fragments.allSatisfy { $0.role == .code })
    }
}
