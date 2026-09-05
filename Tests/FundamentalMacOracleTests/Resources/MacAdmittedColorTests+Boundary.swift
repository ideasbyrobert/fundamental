import Testing

extension MacAdmittedColorTests
{
    @Test("per-color admission cannot rediscover color-space identity")
    func retainedAdmissionBoundary() throws
    {
        let source = try MacOracleRepository.source(
            "Sources/FundamentalMacOracle/Resources/"
                + "MacAdmittedColor.swift"
        )
        for forbidden in [
            "copyICCData",
            "localizedName",
            "PresentationColorSpaceIdentity(",
            "CGColorSpace("
        ]
        {
            #expect(!source.contains(forbidden), "\(forbidden)")
        }
        #expect(source.contains("colorSpace.identity == color.colorSpace"))
        #expect(source.contains("graphics.components?.map(Double.init)"))
    }
}
