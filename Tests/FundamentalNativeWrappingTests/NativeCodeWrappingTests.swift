import Testing

@testable import FundamentalNativeWrapping
@testable import FundamentalWrapping

@Suite("Owned code continuation choices")
struct NativeCodeWrappingTests
{
    @MainActor
    @Test("fitting tokens move together to indented continuation lines")
    func tokens() throws
    {
        let width = NativeCodeFixture.advance("xxxxxxxx")
        let result = try NativeCodeFixture.wrap("alpha beta", width: width)
        #expect(result.lines.map(\.attributed.string) == ["alpha ", "beta"])
        #expect(result.plan.lines[0].breakKind == .soft)
        #expect(result.plan.lines[1].indentation == width / 3)
    }

    @MainActor
    @Test("overlong quoted paths use internal separators before emergencies")
    func paths() throws
    {
        let text = #""/alpha/beta/gamma.swift""#
        let width = NativeCodeFixture.advance(#""/alpha/beta/"#) + 0.01
        let result = try NativeCodeFixture.wrap(text, width: width)
        #expect(result.lines.first?.attributed.string == #""/alpha/beta/"#)
        #expect(result.lines.map(\.attributed.string).joined() == text)
        #expect(result.plan.lines.first?.breakKind == .soft)
    }

    @MainActor
    @Test("a leading internal separator stays with an overlong token")
    func leadingSeparator() throws
    {
        let result = try NativeCodeFixture.wrap(
            ".executableRuntimeMismatch", width: 120
        )
        #expect(result.lines.first?.attributed.string.hasPrefix(".exec")
            == true)
        #expect(!result.lines.contains { $0.attributed.string == "." })
    }

    @MainActor
    @Test("source indentation is retained and generated inset is bounded")
    func indentation() throws
    {
        let text = "        alpha beta gamma delta epsilon"
        let width = NativeCodeFixture.advance("xxxxxxxxxxxxxxxxxxxx")
        let result = try NativeCodeFixture.wrap(text, width: width)
        #expect(result.lines.first?.attributed.string.hasPrefix("        ")
            == true)
        #expect(result.plan.lines.dropFirst().allSatisfy
        {
            $0.indentation == width / 3
        })
        #expect(result.lines.map(\.attributed.string).joined() == text)
    }

    @MainActor
    @Test("one-character widths reduce continuation indent without hyphens")
    func emergency() throws
    {
        let width = NativeCodeFixture.advance("x") + 0.01
        let result = try NativeCodeFixture.wrap("abcdef", width: width)
        #expect(result.lines.map(\.attributed.string)
            == ["a", "b", "c", "d", "e", "f"])
        #expect(result.plan.lines.allSatisfy { $0.indentation == 0 })
        #expect(result.plan.lines.dropLast().allSatisfy
        {
            $0.breakKind == .emergency
        })
    }
}
