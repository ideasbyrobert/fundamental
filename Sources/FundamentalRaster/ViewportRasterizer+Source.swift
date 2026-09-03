import FundamentalViewport

extension ViewportRasterizer
{
    static func sourceSlices(
        _ slices: [ResidentLayoutSourceSlice]
    ) -> [RasterSourceSlice]
    {
        slices.map
        {
            slice in
            let source: RasterTextSource
            switch slice.source
            {
            case let .block(blockID, run, range):
                source = .block(
                    blockID: blockID,
                    run: run,
                    range: range.value
                )
            case let .caption(blockID, run, range):
                source = .caption(
                    blockID: blockID,
                    run: run,
                    range: range.value
                )
            case let .cell(blockID, row, cell, run, range):
                source = .cell(
                    blockID: blockID,
                    row: row,
                    cell: cell,
                    run: run,
                    range: range.value
                )
            }
            let scope: RasterRunScope
            switch slice.scope
            {
            case .direct:
                scope = .direct
            case let .link(destination):
                scope = .link(destination)
            case let .language(identifier):
                scope = .language(identifier)
            case let .linkAndLanguage(link, language):
                scope = .linkAndLanguage(
                    link: link,
                    language: language
                )
            }
            return RasterSourceSlice(
                source: source,
                scope: scope,
                range: slice.range,
                text: slice.text
            )
        }
    }

    static func font(
        _ font: ResidentLayoutFontIdentity
    ) -> RasterFontIdentity
    {
        RasterFontIdentity(
            postScriptName: font.postScriptName,
            uniqueName: font.uniqueName,
            versionName: font.versionName,
            pointSize: font.pointSize,
            matrix: transform(
                a: font.matrix.a,
                b: font.matrix.b,
                c: font.matrix.c,
                d: font.matrix.d,
                tx: font.matrix.tx,
                ty: font.matrix.ty
            ),
            variations: font.variations.map
            {
                RasterFontVariation(axis: $0.axis, value: $0.value)
            },
            metrics: RasterFontMetrics(
                ascent: font.metrics.ascent,
                descent: font.metrics.descent,
                leading: font.metrics.leading,
                capHeight: font.metrics.capHeight,
                xHeight: font.metrics.xHeight,
                underlinePosition: font.metrics.underlinePosition,
                underlineThickness: font.metrics.underlineThickness,
                unitsPerEm: font.metrics.unitsPerEm
            )
        )
    }
}
