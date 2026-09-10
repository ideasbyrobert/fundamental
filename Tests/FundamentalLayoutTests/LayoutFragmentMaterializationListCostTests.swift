import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("generated markers spend glyph and label budgets without source cost")
    func generatedListCost() throws
    {
        for kind in SemanticListKind.allCases
        {
            let value = try product([
                .listItem(SemanticListItem(kind: kind, runs: []))
            ])
            let full = try diagnostics(value, extents: value.index.extents)
            guard case let .lines(fragment) = value.eager.firstFragment
            else
            {
                Issue.record("Expected a list line")
                continue
            }
            let line = fragment.line
            let marker = try #require(line.marker)
            let expectedGlyphs = kind == .numbered ? 2 : 1
            #expect(full.usage.glyphs == expectedGlyphs)
            #expect(full.usage.caretStops == 1)
            #expect(full.usage.sourceSlices == 0)
            #expect(full.usage.decorations == 0)
            var fontUnits = 0
            var variations = 0
            let fonts = [line.defaultFont] + marker.glyphRuns.map(\.font)
            for font in fonts
            {
                fontUnits += font.postScriptName.utf16.count
                    + font.uniqueName.utf16.count + font.versionName.utf16.count
                variations += font.variations.count
            }
            #expect(full.usage.residentUTF16Units == fontUnits + expectedGlyphs)
            #expect(full.usage.fontVariations == variations)
            #expect(line.text.isEmpty)
            #expect(line.glyphRuns.isEmpty)
        }
    }
}
