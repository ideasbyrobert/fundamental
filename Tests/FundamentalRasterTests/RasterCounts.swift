@testable import FundamentalRaster

struct RasterCounts
{
    let marks: Int
    let glyphs: Int
    let fills: Int
    let sourceSlices: Int
    let caretSites: Int
    let interactionRegions: Int
    let fontVariations: Int
    let residentUTF16Units: Int
    let pixelArea: Int

    init(_ snapshot: RasterSnapshot)
    {
        marks = snapshot.marks.count
        glyphs = snapshot.marks.reduce(0)
        {
            guard case let .glyphs(batch) = $1 else { return $0 }
            return $0 + batch.glyphs.count
        }
        fills = snapshot.marks.reduce(0)
        {
            guard case .fill = $1 else { return $0 }
            return $0 + 1
        }
        let markSlices = snapshot.marks.flatMap
        {
            switch $0
            {
            case let .glyphs(batch):
                batch.sourceSlices
                    + batch.glyphs.flatMap(\.sourceSlices)
            case let .fill(fill):
                fill.sourceSlices
            }
        }
        let texts: [RasterInteractionText]
        texts = snapshot.interactionMap.regions.compactMap
        {
            guard case let .text(text) = $0.content else { return nil }
            return text
        }
        let interactionSlices = texts.flatMap(\.sourceSlices)
        let slices = markSlices + interactionSlices
        sourceSlices = slices.count
        caretSites = texts.reduce(0)
        {
            $0 + $1.caretSites.count
        }
        interactionRegions = snapshot.interactionMap.regions.count
        let fonts = snapshot.marks.compactMap
        {
            guard case let .glyphs(batch) = $0 else { return nil }
            return batch.font
        } + texts.map(\.defaultFont)
        fontVariations = fonts.reduce(0)
        {
            $0 + $1.variations.count
        }
        residentUTF16Units = texts.reduce(0)
        {
            $0 + $1.text.utf16.count
        } + slices.reduce(0)
        {
            $0 + $1.text.utf16.count + Self.scopeCount($1.scope)
        } + fonts.reduce(0)
        {
            $0 + Self.fontCount($1)
        }
        pixelArea = snapshot.lineage.specification.pixelBounds.area
    }

    private static func scopeCount(_ scope: RasterRunScope) -> Int
    {
        switch scope
        {
        case .direct:
            0
        case let .link(destination):
            destination.utf16.count
        case let .language(identifier):
            identifier.utf16.count
        case let .linkAndLanguage(link, language):
            link.utf16.count + language.utf16.count
        }
    }

    private static func fontCount(_ font: RasterFontIdentity) -> Int
    {
        font.postScriptName.utf16.count
            + font.uniqueName.utf16.count
            + font.versionName.utf16.count
    }
}
