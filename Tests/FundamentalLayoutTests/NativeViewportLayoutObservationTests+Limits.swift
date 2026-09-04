import Testing

extension NativeViewportLayoutObservationTests
{
    @MainActor
    @Test("one enormous paragraph exposes complete prepared line work")
    func enormousParagraph() throws
    {
        let text = String(
            repeating: "one indivisible native paragraph boundary ",
            count: 4_000
        )
        let fixture = NativeViewportObservationFixture(
            text: text,
            width: 160,
            height: 240
        )
        let fragments = fixture.unique(fixture.layout()).sorted
        {
            fixture.sourceRange($0).lowerBound
                < fixture.sourceRange($1).lowerBound
        }
        let first = try #require(fragments.first)
        let last = try #require(fragments.last)
        let ranges = fragments.map(fixture.sourceRange)
        #expect(fixture.sourceRange(first).lowerBound == 0)
        #expect(fixture.sourceRange(last).upperBound
            == fixture.sourceLength)
        #expect(zip(ranges, ranges.dropFirst()).allSatisfy
        {
            $0.upperBound == $1.lowerBound
        })
        #expect(fragments.allSatisfy
        {
            $0.state == .layoutAvailable
        })
        #expect(fragments.flatMap(\.textLineFragments).count > 1_000)
    }

    @MainActor
    @Test("native fragments preserve demanding Unicode source spelling")
    func unicode() throws
    {
        let text = [
            "Composed café and decomposed cafe\u{301}.",
            "Arabic مرحبا and Hebrew שלום.",
            "Emoji 👩🏽‍💻, flag 🇦🇲, and variation ✈️."
        ].joined(separator: "\n")
        let fixture = NativeViewportObservationFixture(
            text: text,
            width: 500,
            height: 1_000
        )
        let fragments = fixture.unique(fixture.layout()).sorted
        {
            fixture.sourceRange($0).lowerBound
                < fixture.sourceRange($1).lowerBound
        }
        let spelling = fragments.map
        {
            fixture.text(of: $0)
        }.joined()
        let ranges = fragments.map(fixture.sourceRange)
        #expect(spelling == text)
        #expect(ranges.first?.lowerBound == 0)
        #expect(ranges.last?.upperBound == fixture.sourceLength)
        #expect(zip(ranges, ranges.dropFirst()).allSatisfy
        {
            $0.upperBound == $1.lowerBound
        })
        #expect(fragments.allSatisfy
        {
            $0.state == .layoutAvailable
                && !$0.textLineFragments.isEmpty
        })
    }
}
