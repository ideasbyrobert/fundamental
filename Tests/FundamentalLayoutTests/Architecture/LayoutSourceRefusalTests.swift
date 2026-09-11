import Darwin
import Foundation
import Testing

@Suite("Incomplete layout source discovery is refused")
struct LayoutSourceRefusalTests
{
    @Test("the source root must exist and be a directory")
    func rootKind() throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        try fixture.write("File.swift", Data())
        for path in ["Missing", "File.swift"]
        {
            let sources = LayoutArchitectureSources(
                directory: fixture.root.appendingPathComponent(path)
            )
            #expect(throws: CocoaError.self)
            {
                try sources.text()
            }
        }
    }

    @Test("invalid nested UTF-8 cannot produce partial source text")
    func invalidText() throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        try fixture.write("LayoutGood.swift", Data("valid".utf8))
        try fixture.write("Nested/LayoutBad.swift", Data([0xC3, 0x28]))
        #expect(throws: CocoaError.self)
        {
            try fixture.sources.text()
        }
    }

    @Test("a named pipe is refused without opening it")
    func unsupportedEntry() throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        let pipe = fixture.root.appendingPathComponent("LayoutPipe.swift")
        try #require(mkfifo(pipe.path, 0o600) == 0)
        #expect(throws: CocoaError.self)
        {
            try fixture.sources.text()
        }
    }

    @Test("unreadable nested entries fail", arguments: [false, true])
    func permissions(directory: Bool) throws
    {
        let fixture = try LayoutSourceFixture()
        defer { fixture.remove() }
        try fixture.write("LayoutGood.swift", Data("valid".utf8))
        try fixture.write("Nested/LayoutValue.swift", Data("nested".utf8))
        let path = fixture.root.appendingPathComponent(
            directory ? "Nested" : "Nested/LayoutValue.swift"
        ).path
        try FileManager.default.setAttributes(
            [.posixPermissions: 0], ofItemAtPath: path
        )
        defer
        {
            try? FileManager.default.setAttributes(
                [.posixPermissions: directory ? 0o700 : 0o600],
                ofItemAtPath: path
            )
        }
        #expect(throws: CocoaError.self)
        {
            try fixture.sources.text()
        }
    }
}
