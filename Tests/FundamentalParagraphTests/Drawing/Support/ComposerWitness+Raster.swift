import CoreGraphics
import FundamentalNativeParagraph

extension ComposerWitness
{
    static func raster(
        _ paragraphs: [ParagraphComposition]
    ) throws -> SpacingRaster
    {
        let count = paragraphs.flatMap(\.segments).flatMap(\.lines).count
        let height = Double(count) * 29 + 112
        return try SpacingRaster(width: 384, height: height, scale: 2)
        {
            context in
            var baseline = height - 44
            for paragraph in paragraphs
            {
                for plan in paragraph.segments.flatMap(\.lines)
                {
                    let line = try SpacedNativeLine(plan)
                    line.draw(
                        in: context, origin: CGPoint(x: 32, y: baseline),
                        ink: CGColor(gray: 0, alpha: 1)
                    )
                    baseline -= 29
                }
                baseline -= 28
            }
        }
    }
}
