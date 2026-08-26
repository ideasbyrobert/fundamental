import Foundation
import Testing

@testable import lint

@Suite("Finding every Swift file in a package")
struct SourceTreeTests
{
    @Test("the root is found by walking up to the manifest")
    func packageRootIsFound() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        try fixture.write("Sources/Example/Nested/Value.swift", "")
        let file = fixture.root.appendingPathComponent(
            "Sources/Example/Nested/Value.swift"
        )
        let found = SourceTree(containing: file.path)
        #expect(
            found?.location(of: file)
                == "Sources/Example/Nested/Value.swift"
        )
    }

    @Test("package, source, and test Swift files are included")
    func packageFilesAreIncluded() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        try fixture.write("Sources/Example/Value.swift", "")
        try fixture.write("Tests/ExampleTests/ValueTests.swift", "")
        let names = try fixture.tree.swiftFiles().map(\.lastPathComponent)
        #expect(names == [
            "Package.swift", "Value.swift", "ValueTests.swift"
        ])
    }

    @Test("build output is excluded")
    func buildOutputIsExcluded() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        try fixture.write(".build/Generated.swift", "struct Bad {")
        #expect(try fixture.tree.swiftFiles().map(\.lastPathComponent) == [
            "Package.swift"
        ])
    }

    @Test("an absent package root is not an empty package")
    func absentRootFails() throws
    {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let tree = SourceTree(root: root)
        #expect(throws: CocoaError.self)
        {
            try tree.swiftFiles()
        }
    }

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
