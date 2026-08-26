import Testing

@testable import lint

@Suite("The lint process boundary")
struct LintTests
{
    @Test("a clean package exits successfully and says nothing")
    func cleanPackageSucceeds() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        var output: [String] = []
        var failure: [String] = []
        let status = Lint.run(
            tree: fixture.tree,
            output: { output.append($0) },
            failure: { failure.append($0) }
        )
        #expect(status == 0)
        #expect(output.isEmpty)
        #expect(failure.isEmpty)
    }

    @Test("violations exit one and are reported")
    func violationsFail() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        try fixture.write("Sources/Example/Bad.swift", "struct Bad {\n")
        var output: [String] = []
        var failure: [String] = []
        let status = Lint.run(
            tree: fixture.tree,
            output: { output.append($0) },
            failure: { failure.append($0) }
        )
        #expect(status == 1)
        #expect(output.first?.contains("braces") == true)
        #expect(output.last == "1 violation")
        #expect(failure.isEmpty)
    }

    @Test("an unavailable package exits as an operational failure")
    func missingPackageFailsOperationally()
    {
        var output: [String] = []
        var failure: [String] = []
        let status = Lint.run(
            tree: nil,
            output: { output.append($0) },
            failure: { failure.append($0) }
        )
        #expect(status == 2)
        #expect(output.isEmpty)
        #expect(failure == ["lint: no package found"])
    }
}
