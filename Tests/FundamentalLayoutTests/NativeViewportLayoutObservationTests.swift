import Testing

@Suite("Native viewport layout observation", .serialized)
struct NativeViewportLayoutObservationTests
{
    @MainActor
    @Test("many paragraphs configure a strict local fragment collection")
    func manyParagraphs() throws
    {
        let paragraphCount = 1_000
        let text = Self.paragraphs(count: paragraphCount)
        let fixture = NativeViewportObservationFixture(
            text: text,
            width: 320,
            height: 240
        )
        let fragments = fixture.layout()
        let range = try #require(fixture.viewportRange())
        let configured = fixture.sourceRanges(fragments)
        let first = try #require(configured.first)
        let last = try #require(configured.last)
        #expect(!fragments.isEmpty)
        #expect(range.count > 0)
        #expect(range.count < fixture.sourceLength)
        #expect(configured.allSatisfy
        {
            !$0.isEmpty && $0.lowerBound >= 0
                && $0.upperBound <= fixture.sourceLength
        })
        #expect(first.lowerBound <= range.lowerBound)
        #expect(last.upperBound >= range.upperBound)
        #expect(last.upperBound - first.lowerBound < fixture.sourceLength)
        #expect(fragments.allSatisfy
        {
            $0.state == .layoutAvailable
                && !$0.textLineFragments.isEmpty
        })
    }

    @MainActor
    @Test("relocation reaches another strict local source range")
    func relocation() throws
    {
        let paragraphCount = 1_000
        let text = Self.paragraphs(count: paragraphCount)
        let fixture = NativeViewportObservationFixture(
            text: text,
            width: 320,
            height: 240
        )
        let initialFragments = fixture.layout()
        let initialConfigured = fixture.sourceRanges(initialFragments)
        let initial = try #require(fixture.viewportRange())
        let midpoint = fixture.sourceLength / 2
        let fragments = try #require(
            fixture.relocate(toUTF16Offset: midpoint)
        )
        let relocated = try #require(fixture.viewportRange())
        let relocatedConfigured = fixture.sourceRanges(fragments)
        let first = try #require(relocatedConfigured.first)
        let last = try #require(relocatedConfigured.last)
        #expect(!fragments.isEmpty)
        #expect(relocatedConfigured != initialConfigured)
        #expect(relocated != initial)
        #expect(!initial.contains(midpoint))
        #expect(relocated.contains(midpoint))
        #expect(relocated.count < fixture.sourceLength)
        #expect(relocatedConfigured.contains
        {
            $0.contains(midpoint)
        })
        #expect(first.lowerBound <= relocated.lowerBound)
        #expect(last.upperBound >= relocated.upperBound)
        #expect(last.upperBound - first.lowerBound < fixture.sourceLength)
    }

    static func paragraphs(count: Int) -> String
    {
        (0 ..< count).map
        {
            "Paragraph \($0) carries exact native viewport evidence."
        }.joined(separator: "\n")
    }
}
