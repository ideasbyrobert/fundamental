import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

@Suite("Viewport residence")
struct ViewportResidenceTests
{
    @MainActor
    @Test("visible and two directional overscan residents are admitted")
    func directionalOverscan() throws
    {
        let layout = try ViewportFixture.layout()
        let fragments = layout.fragments
        let target = fragments[5]
        let bounds = try ViewportFixture.bounds(of: target)
        let preceding = bounds.minY - fragments[2].frame.minY
        let following = fragments[8].frame.maxY - bounds.maxY
        let request = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            preceding: preceding,
            following: following,
            limit: 5
        )
        let snapshot = try #require(ViewportSnapshot(
            layout,
            request: request
        ))
        let values = snapshot.residents.all
        #expect(values.count == 5)
        #expect(values.contains
        {
            $0.residence == .visible && $0.fragment == target
        })
        #expect(values.contains
        {
            $0.residence == .overscan(.preceding)
        })
        #expect(values.contains
        {
            $0.residence == .overscan(.following)
        })
        #expect(values.map(\.fragment.frame.minY).sorted()
            == values.map(\.fragment.frame.minY))
    }

    @MainActor
    @Test("half-open visible bounds exclude adjacent lines")
    func halfOpenBoundary() throws
    {
        let layout = try ViewportFixture.layout()
        let target = layout.fragments[4]
        let bounds = try ViewportFixture.bounds(of: target)
        let request = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            limit: 4
        )
        let snapshot = try #require(ViewportSnapshot(
            layout,
            request: request
        ))
        #expect(snapshot.residents.all == [ResidentLayoutFragment(
            residence: .visible,
            fragment: target
        )])
    }

    @MainActor
    @Test("nearest overscan wins limited capacity deterministically")
    func nearestCapacity() throws
    {
        let layout = try ViewportFixture.layout()
        let fragments = layout.fragments
        let target = fragments[5]
        let bounds = try ViewportFixture.bounds(of: target)
        let request = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            preceding: bounds.minY - fragments[2].frame.minY,
            following: fragments[8].frame.maxY - bounds.maxY,
            limit: 2
        )
        let snapshot = try #require(ViewportSnapshot(
            layout,
            request: request
        ))
        let overscan = try #require(snapshot.residents.all.first
        {
            $0.residence != .visible
        })
        #expect(overscan.residence == .overscan(.preceding))
        #expect(overscan.fragment == fragments[4])
    }
}
