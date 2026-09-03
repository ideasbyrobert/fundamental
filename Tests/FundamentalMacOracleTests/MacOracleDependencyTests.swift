import Testing

extension MacOracleArchitectureTests
{
    @Test("the application and oracle keep the immediate dependency graph")
    func packageKeepsImmediateDependencies() throws
    {
        let package = try MacOracleRepository.source("Package.swift")
        #expect(package.contains(
            "name: \"FundamentalMacOracle\",\n"
                + "            dependencies: "
                + "[\"FundamentalPresentation\"]"
        ))
        #expect(package.contains(
            "name: \"FundamentalApplication\",\n"
                + "            dependencies: "
                + "[\"FundamentalMacOracle\"]"
        ))
        let application = try MacOracleRepository.swiftSources(
            "Sources/FundamentalApplication"
        ).joined()
        #expect(application.contains("import FundamentalMacOracle"))
        #expect(!application.contains("import AppKit"))
        #expect(!application.contains("import FundamentalPresentation"))
    }

    @Test("the macOS oracle imports no earlier semantic stage")
    func oracleImportsOnlyPresentation() throws
    {
        let source = try MacOracleRepository.swiftSources(
            "Sources/FundamentalMacOracle"
        ).joined(separator: "\n")
        let refused = [
            "FundamentalDocument",
            "FundamentalProjection",
            "FundamentalLayout",
            "FundamentalViewport",
            "FundamentalRaster"
        ]
        for module in refused
        {
            #expect(!source.contains("import \(module)"))
        }
        #expect(source.contains("import FundamentalPresentation"))
        #expect(!source.contains("NSAttributedString"))
        #expect(!source.contains("CTLineCreate"))
    }
}
