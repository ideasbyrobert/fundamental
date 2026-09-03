import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacRasterExecutorTests
{
    @Test("selection fill precedes and preserves prose glyphs")
    func proseSelectionKeepsFillAndGlyphs() throws
    {
        let model = try MacOracleTestSurface.model()
        let (resident, line) = try MacReaderInteractionTests.line(
            in: model.snapshot
        )
        try assertSelectionOrder(
            model: model,
            resident: resident,
            line: line
        )
    }

    @Test("selection follows table fills and precedes cell glyphs")
    func tableSelectionKeepsFillAndGlyphs() throws
    {
        let model = try MacOracleTestSurface.model(width: 320)
        #expect(model.update(
            viewportWidth: 320,
            viewportHeight: 680,
            visibleOriginY: model.documentHeight,
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance()
        ))
        let resident = try #require(
            model.snapshot.presentedDocument.residents.all.first
            {
                guard case let .headerCell(_, _, .line(line))
                        = $0.content
                else
                {
                    return false
                }
                return line.caretSites.count > 2
            }
        )
        guard case let .headerCell(_, _, .line(line)) = resident.content
        else
        {
            throw MacOracleTestFailure.admission
        }
        try assertSelectionOrder(
            model: model,
            resident: resident,
            line: line
        )
    }
}
