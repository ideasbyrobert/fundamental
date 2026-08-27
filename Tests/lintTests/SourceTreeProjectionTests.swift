import Testing

@testable import lint

extension SourceTreeTests
{
    @Test("line terminators are not source characters")
    func carriageReturnsAreRemoved() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        try fixture.write("Sources/Example/Value.swift", "let value = 1\r\n")
        let file = fixture.root.appendingPathComponent(
            "Sources/Example/Value.swift"
        )
        let lines = try fixture.tree.lines(of: file)
        #expect(lines.first?.text == "let value = 1")
        #expect(lines.first?.width == 13)
    }

    @Test("locations are relative to the package root")
    func locationsAreRelative() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        let file = fixture.root.appendingPathComponent(
            "Sources/Example/Value.swift"
        )
        #expect(
            fixture.tree.location(of: file)
                == "Sources/Example/Value.swift"
        )
    }
}
