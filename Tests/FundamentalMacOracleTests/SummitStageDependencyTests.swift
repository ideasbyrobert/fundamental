import Foundation
import Testing

extension MacOracleArchitectureTests
{
    @Test("each summit preparation imports only its predecessor")
    func summitPreparationsKeepStageOrder() throws
    {
        let expected = [
            (
                "Sources/FundamentalProjection/Summit",
                "FundamentalDocument"
            ),
            (
                "Sources/FundamentalLayout/"
                    + "SummitLayoutPreparation.swift",
                "FundamentalProjection"
            ),
            (
                "Sources/FundamentalViewport/"
                    + "SummitViewportPreparation.swift",
                "FundamentalLayout"
            ),
            (
                "Sources/FundamentalRaster/"
                    + "SummitRasterPreparation.swift",
                "FundamentalViewport"
            )
        ]
        for (path, predecessor) in expected
        {
            let url = MacOracleRepository.root.appending(path: path)
            let values = try url.resourceValues(
                forKeys: [.isDirectoryKey]
            )
            let source = values.isDirectory == true
                ? try MacOracleRepository.swiftSources(path).joined()
                : try MacOracleRepository.source(path)
            #expect(source.contains("import \(predecessor)"))
        }
        let presentation = try MacOracleRepository.swiftSources(
            "Sources/FundamentalPresentation/Summit"
        ).joined()
        #expect(presentation.contains("import FundamentalRaster"))
    }
}
