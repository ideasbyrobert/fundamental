import Testing

@testable import FundamentalMacOracle

extension MacAdmissionObservationTests
{
    @Test("ordered color admission keeps an already admitted color space")
    func colors() throws
    {
        let workload = MacAdmissionWorkload(
            try MacOracleTestSurface.snapshot()
        )
        workload.report("colors")
        let space = try #require(MacAdmittedColorSpace(
            workload.snapshot.presentedDocument.plane.colorSpace
        ))
        _ = try MacAdmissionMeasurement.measure(
            "colors",
            prepare: { _ in workload.colors },
            action:
            {
                $0.map { MacAdmittedColor($0, colorSpace: space) }
            },
            consume:
            {
                colors, admitted in
                #expect(admitted.count == colors.count)
                for (color, value) in zip(colors, admitted)
                {
                    let value = try #require(value)
                    #expect(value.graphics.components?.map(Double.init)
                        == color.components + [color.alpha])
                }
            }
        )
    }

    @Test("ordered font admission retains every exact source spelling")
    func fonts() throws
    {
        let workload = MacAdmissionWorkload(
            try MacOracleTestSurface.snapshot()
        )
        workload.report("fonts")
        _ = try MacAdmissionMeasurement.measure(
            "fonts",
            prepare: { _ in workload.fonts },
            action:
            {
                $0.map
                {
                    MacAdmittedFont($0.identity, sourceText: $0.text)
                }
            },
            consume:
            {
                fonts, admitted in
                #expect(admitted.count == fonts.count)
                for font in admitted
                {
                    _ = try #require(font)
                }
            }
        )
    }
}
