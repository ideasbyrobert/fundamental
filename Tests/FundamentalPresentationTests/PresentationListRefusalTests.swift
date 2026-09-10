import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

@Suite("Malformed list presentation refusal")
@MainActor
struct PresentationListRefusalTests
{
    @Test("malformed marker ownership and canonical source are refused",
          arguments: PresentationListFault.allCases)
    func malformed(fault: PresentationListFault) throws
    {
        let raster = try PresentationListFixture.raster(.numbered, count: 2)
        let malformed = try PresentationListFixture.corrupt(
            raster, fault: fault
        )
        #expect(PresentationComposer().present(
            malformed, request: try PresentationFixture.request(malformed)
        ) == nil)
        #expect(PresentationComposer().present(
            raster, request: try PresentationFixture.request(raster)
        ) != nil)
    }

    @Test("continuations cannot change list context or repeat a marker",
          arguments: [0, 1, 2, 3, 4])
    func continuation(fault: Int) throws
    {
        let raster = try PresentationListFixture.raster(
            .numbered, text: "First\nSecond", count: 2
        )
        var regions = raster.interactionMap.regions
        try #require(regions.count == 4)
        guard case let .text(first) = regions[0].content,
              case let .text(second) = regions[1].content
        else { throw PresentationListTestFailure.missingText }
        let position = try #require(RasterListPosition(
            index: fault == 2 ? 1 : 0, count: fault == 3 ? 3 : 2
        ))
        let role: RasterInteractionRole
        switch fault
        {
        case 0: role = .body
        case 1: role = .bulleted(position)
        default: role = .numbered(position)
        }
        regions[1] = try PresentationListFixture.region(
            regions[1], role: role,
            marker: fault == 4 ? first.marker : second.marker
        )
        let changed = try PresentationListFixture.replacing(
            raster, regions: regions
        )
        #expect(PresentationComposer().present(
            changed, request: try PresentationFixture.request(changed)
        ) == nil)
    }
}
