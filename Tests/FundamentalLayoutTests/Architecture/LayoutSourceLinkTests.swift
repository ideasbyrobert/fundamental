import Foundation
import Testing

@Suite("Layout source discovery refuses symbolic links")
struct LayoutSourceLinkTests
{
    @Test("aliases, cycles and broken links fail", arguments: [
        "LayoutValue.swift", "Nested", ".", "Missing"
    ])
    func symbolicEntry(destination: String) throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        try fixture.write("LayoutValue.swift", Data("top".utf8))
        try fixture.write("Nested/LayoutValue.swift", Data("nested".utf8))
        try FileManager.default.createSymbolicLink(
            at: fixture.root.appendingPathComponent("Alias.swift"),
            withDestinationURL: fixture.root.appendingPathComponent(
                destination
            )
        )
        #expect(throws: CocoaError.self)
        {
            try fixture.sources.text()
        }
    }

    @Test("the root cannot be a symbolic directory alias")
    func symbolicRoot() throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        try fixture.write("Nested/LayoutValue.swift", Data("nested".utf8))
        let alias = fixture.root.appendingPathComponent("Alias")
        try FileManager.default.createSymbolicLink(
            at: alias,
            withDestinationURL: fixture.root.appendingPathComponent("Nested")
        )
        let sources = LayoutArchitectureSources(directory: alias)
        #expect(throws: CocoaError.self)
        {
            try sources.text()
        }
    }
}
