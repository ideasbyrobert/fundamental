import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

@Suite("Wrapped native source lineage")
struct LayoutWrappedSourceTests
{
    @MainActor
    @Test("every wrapped slice retains its exact projected run")
    func wrappedRuns() throws
    {
        let first = "First projected run wraps across several lines. "
        let second = "Second projected run remains independently sourced."
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(first),
            try LayoutFixture.scoped(second)
        ]))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 80)
        )
        let lines: [LayoutLine] = snapshot.fragments.compactMap
        {
            fragment -> LayoutLine? in
            guard case let .lines(lineFragment) = fragment
            else
            {
                return nil
            }
            return lineFragment.line
        }
        let slices = lines.flatMap(\.sourceSlices)
        let blockID = LayoutFixture.blockID(0)
        let boundary = first.utf16.count
        let end = boundary + second.utf16.count
        #expect(slices.map(\.text).joined() == first + second)
        var offset = 0
        for slice in slices
        {
            let nextOffset = offset + slice.text.utf16.count
            #expect(slice.range == offset ..< nextOffset)
            if nextOffset <= boundary
            {
                #expect(slice.source == .block(
                    blockID: blockID,
                    run: 0,
                    range: ProjectedUTF16Range(0 ..< boundary)
                ))
            }
            else
            {
                #expect(slice.source == .block(
                    blockID: blockID,
                    run: 1,
                    range: ProjectedUTF16Range(boundary ..< end)
                ))
            }
            offset = nextOffset
        }
        #expect(offset == end)
    }
}
