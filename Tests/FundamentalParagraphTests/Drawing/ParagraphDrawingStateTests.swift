import CoreGraphics
import FundamentalNativeParagraph
import Testing

@MainActor
struct ParagraphDrawingStateTests
{
    @Test func drawingPreservesCallerTextTransformPositionAndPath() throws
    {
        var records: [[String: Any]] = []
        for text in ["", "AVATAR a b", "👩‍💻 a"]
        {
            for size in [18.0, 36]
            {
                let line = try SpacingFixture.text(text, size: size)
                _ = try SpacingRaster(
                    width: line.advance + 80, height: 160, scale: 2
                )
                {
                    context in
                    context.textMatrix = CGAffineTransform(
                        a: 1.25, b: 0.125, c: -0.25, d: 1.5, tx: 7, ty: 9
                    )
                    context.textPosition = CGPoint(x: 23.25, y: 51.5)
                    context.move(to: CGPoint(x: 3, y: 5))
                    context.addLine(to: CGPoint(x: 17, y: 19))
                    let matrix = context.textMatrix
                    let position = context.textPosition
                    let transform = context.ctm
                    let path = try #require(context.path)
                    line.draw(
                        in: context, origin: SpacingFixture.origin,
                        ink: CGColor(gray: 0, alpha: 1)
                    )
                    #expect(context.textMatrix == matrix)
                    #expect(context.textPosition == position)
                    #expect(context.ctm == transform)
                    #expect(context.path == path)
                    records.append([
                        "text": text, "size": size,
                        "before": ShapingEvidence.matrix(matrix),
                        "after": ShapingEvidence.matrix(context.textMatrix),
                        "positionBefore": [position.x, position.y],
                        "positionAfter": [
                            context.textPosition.x, context.textPosition.y
                        ]
                    ])
                }
            }
        }
        try PatternEvidence.write(
            "state", group: "drawing-context-controls",
            record: ["observations": records]
        )
    }
}
