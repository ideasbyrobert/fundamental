import Testing

@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    @Test("the immutable index retains only lightweight exact facts")
    func lightweightStorage() throws
    {
        let first = try product(try mixedBlocks(), width: 360).index
        let second = try product(try mixedBlocks(), width: 360).index
        requireSendable(first)
        requireSendable(try capacity())
        #expect(first == second)
        let fields = Set(Mirror(reflecting: first).children.compactMap(\.label))
        #expect(fields.contains("extents"))
        #expect(!fields.contains("firstExtent"))
        #expect(!fields.contains("remainingExtents"))
        let forbidden: Set<String> = [
            "LayoutBlockMeasurement",
            "LayoutFragment",
            "LayoutLine",
            "LayoutGrid",
            "LayoutGlyph",
            "LayoutGlyphRun",
            "LayoutCaretStop",
            "LayoutSourceSlice",
            "LayoutDecoration"
        ]
        #expect(storedTypeTokens(first).isDisjoint(with: forbidden))
    }

    func requireSendable<T: Sendable>(_ value: T)
    {
        _ = value
    }

    func storedTypeTokens(_ value: Any) -> Set<String>
    {
        let name = String(reflecting: type(of: value))
        var tokens = Set(name.split
        {
            !$0.isLetter && !$0.isNumber && $0 != "_"
        }.map(String.init))
        for child in Mirror(reflecting: value).children
        {
            tokens.formUnion(storedTypeTokens(child.value))
        }
        return tokens
    }
}
