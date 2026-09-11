import Foundation
import Testing

@Suite("Complete layout architecture source discovery")
struct LayoutSourceDiscoveryTests
{
    @Test("nested Swift files have a complete stable path order")
    func inventory() throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        let paths = [
            "Z/LayoutValue.swift",
            "A/NativeValue.swift",
            "A/Folder.swift/LayoutValue.swift",
            "LayoutValue.swift",
            ".Hidden/LayoutValue.swift"
        ]
        for path in paths.reversed()
        {
            try fixture.write(path, Data(path.utf8))
        }
        try fixture.write("A/Notes.md", Data("not source".utf8))
        try FileManager.default.createDirectory(
            at: fixture.root.appendingPathComponent("Empty"),
            withIntermediateDirectories: false
        )
        let expected = paths.sorted().map
        {
            fixture.root.appendingPathComponent($0).path
        }
        #expect(try fixture.sources.files().map(\.path) == expected)
        #expect(try fixture.sources.files().map(\.path) == expected)
        #expect(try fixture.sources.text() == paths.sorted().joined())
    }

    @Test("provider selection uses the filename at every depth")
    func providerSelection() throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        try fixture.write("Layout/NativeValue.swift", Data("native".utf8))
        try fixture.write("Native/LayoutValue.swift", Data("layout".utf8))
        try fixture.write("LayoutTop.swift", Data("top".utf8))
        let source = try fixture.sources.text { $0.hasPrefix("Layout") }
        #expect(source == "toplayout")
        #expect(try fixture.sources.text() == "nativetoplayout")
    }

    @Test("source spelling and line endings remain byte exact")
    func spelling() throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        let first = Data("é e\u{301} 👩‍💻\r\n".utf8)
        let second = Data("Հայ район\n".utf8)
        try fixture.write("A/LayoutFirst.swift", first)
        try fixture.write("Z/LayoutSecond.swift", second)
        #expect(try Data(fixture.sources.text().utf8) == first + second)
    }

    @Test("an empty directory has no source files")
    func empty() throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        #expect(try fixture.sources.files().isEmpty)
        #expect(try fixture.sources.text().isEmpty)
    }
}
