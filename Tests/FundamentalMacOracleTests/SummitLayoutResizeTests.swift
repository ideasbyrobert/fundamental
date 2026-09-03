import Testing

@testable import FundamentalMacOracle

extension SummitLayoutReuseTests
{
    @Test("far narrow residence clamps after a wide short layout")
    func farNarrowToWideShortClamps() throws
    {
        let model = try MacOracleTestSurface.model()
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        #expect(model.update(
            viewportWidth: 600,
            viewportHeight: 300,
            visibleOriginY: .greatestFiniteMagnitude,
            screen: screen,
            appearance: appearance
        ))
        #expect(model.layoutExecutionCount == 2)
        #expect(model.update(
            viewportWidth: 1_200,
            viewportHeight: 300,
            visibleOriginY: .greatestFiniteMagnitude,
            screen: screen,
            appearance: appearance
        ))
        #expect(model.layoutExecutionCount == 3)
        #expect(model.visibleOriginY >= 0)
        #expect(model.visibleOriginY + 300 <= model.documentHeight)
    }
}
