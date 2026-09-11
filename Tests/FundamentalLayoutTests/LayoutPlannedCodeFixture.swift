import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@MainActor
enum LayoutPlannedCodeFixture
{
    static func lines(
        _ runs: [SemanticRun], width: Double, size: Double = 18,
        x: Double = 0, y: Double = 0
    ) throws -> [LayoutLine]
    {
        let projection = try LayoutFixture.projection([
            .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        ])
        guard case let .code(source, code) = projection.firstBlock
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        return try NativeTextKit2Layout().plannedCodeLines(
            runs: code.runs, width: width, originX: x, originY: y,
            font: .monospacedSystemFont(ofSize: size, weight: .regular),
            pointContext: .block(source.blockID)
        )
    }
}
