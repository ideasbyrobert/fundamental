import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func proseLines(
        _ prose: ProjectedProse,
        source: ProjectedBlockSource,
        width: Double,
        originY: Double
    ) throws -> [LayoutLine]
    {
        if let markerSource = LayoutListMarkerSource(
            block: source, role: prose.role
        )
        {
            return try listLines(
                prose, source: markerSource, width: width, originY: originY
            )
        }
        return try textLines(
            runs: prose.runs,
            width: width,
            originX: 0,
            originY: originY,
            font: try proseFont(prose.role),
            pointContext: .block(source.blockID)
        )
    }

    func codeLines(
        _ code: ProjectedCode,
        source: ProjectedBlockSource,
        width: Double,
        originY: Double
    ) throws -> [LayoutLine]
    {
        try textLines(
            runs: code.runs,
            width: width,
            originX: 0,
            originY: originY,
            font: .monospacedSystemFont(
                ofSize: 15,
                weight: .regular
            ),
            pointContext: .block(source.blockID)
        )
    }
}
