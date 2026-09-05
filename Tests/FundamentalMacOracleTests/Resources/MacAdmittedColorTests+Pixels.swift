import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAdmittedColorTests
{
    @Test(
        "admitted colors draw the same pixels as direct native construction",
        arguments: [NSAppearance.Name.aqua, .darkAqua]
    )
    func exactNativePixels(appearance: NSAppearance.Name) throws
    {
        let snapshot = try MacOracleTestSurface.snapshot(
            appearanceName: appearance
        )
        let workload = MacAdmissionWorkload(snapshot)
        let space = try #require(MacAdmittedColorSpace(
            snapshot.presentedDocument.plane.colorSpace
        ))
        let expected = try #require(MacBitmapSurface(snapshot))
        let actual = try #require(MacBitmapSurface(snapshot))
        let width = workload.colors.count * 8
        try #require(width <= actual.width)
        try #require(expected.height == actual.height && actual.height >= 8)
        for (index, color) in workload.colors.enumerated()
        {
            let components = (color.components + [color.alpha]).map
            {
                CGFloat($0)
            }
            let native = try #require(CGColor(
                colorSpace: space.graphics,
                components: components
            ))
            let admitted = try #require(MacAdmittedColor(
                color,
                colorSpace: space
            ))
            let bounds = CGRect(x: index * 8, y: 0, width: 8, height: 8)
            expected.context.setFillColor(native)
            actual.context.setFillColor(admitted.graphics)
            expected.context.fill(bounds)
            actual.context.fill(bounds)
        }
        let expectedPixels = (0 ..< width).map
        {
            expected.pixel(x: $0, y: expected.height - 1)
        }
        #expect(Set(expectedPixels).count > 1)
        for y in (expected.height - 8) ..< expected.height
        {
            #expect((0 ..< width).map
            {
                actual.pixel(x: $0, y: y)
            } == (0 ..< width).map
            {
                expected.pixel(x: $0, y: y)
            })
        }
    }
}
