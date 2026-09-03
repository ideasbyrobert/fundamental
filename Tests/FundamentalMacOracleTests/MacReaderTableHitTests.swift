import AppKit
import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacReaderInteractionTests
{
    @Test("a table click resolves the horizontally nearest cell")
    func tableClickResolvesHorizontalCell() throws
    {
        let model = try MacOracleTestSurface.model(width: 320)
        let height = 680.0
        #expect(model.update(
            viewportWidth: 320,
            viewportHeight: height,
            visibleOriginY: model.documentHeight,
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance()
        ))
        let witness = try #require(
            model.snapshot.presentedDocument.residents.all.first
            {
                guard case let .headerCell(_, cell, .line(line))
                        = $0.content
                else
                {
                    return false
                }
                return cell == 2 && !line.caretSites.isEmpty
            }
        )
        guard case let .headerCell(_, _, .line(line)) = witness.content
        else
        {
            throw MacOracleTestFailure.admission
        }
        let site = try #require(line.caretSites.dropFirst().first)
        let point = try #require(PresentationPoint(
            x: site.position.x,
            y: site.position.y
        ))
        #expect(model.nearestPosition(to: point)
            == PresentationTextPosition(
                residentID: witness.residentID,
                sourcePoint: site.sourcePoint
            ))
    }

    @Test("a far trailing click stays on its exact visual line")
    func farTrailingClickStaysOnVisualLine() throws
    {
        let model = try MacOracleTestSurface.model()
        let (resident, line) = try Self.line(in: model.snapshot)
        let site = try #require(line.caretSites.first)
        let point = try #require(PresentationPoint(
            x: 10_000,
            y: site.position.y
        ))
        #expect(model.nearestPosition(to: point)?.residentID
            == resident.residentID)
    }
}
