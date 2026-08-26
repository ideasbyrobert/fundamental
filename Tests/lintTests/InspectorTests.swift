import Foundation
import Testing

@testable import lint

@Suite("The normative standard, measured")
struct InspectorTests
{
    @Test("a package satisfying every rule reports nothing")
    func cleanPackageIsSilent() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        try fixture.write(
            "Sources/Example/Clean.swift",
            "struct Clean\n{\n}\n"
        )
        #expect(try fixture.violations().isEmpty)
    }

    @Test("the three normative failures are named and located")
    func normativeFailuresAreReported() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        let long = String(repeating: "x", count: 81)
        try fixture.write(
            "Sources/Example/Bad.swift",
            "struct Bad {\nlet value = 1 // note\n\(long)\n}\n"
        )
        let violations = try fixture.violations()
        #expect(violations.map(\.rule) == [
            "braces", "comments", "width"
        ])
        #expect(violations.map(\.line) == [1, 2, 3])
    }

    @Test("source strings do not manufacture violations")
    func sourceStringsAreIgnored() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        let source = "let url = \"https://example.test/{\"\n"
        try fixture.write("Sources/Example/String.swift", source)
        #expect(try fixture.violations().isEmpty)
    }

    @Test("conventional rules are not promoted into lint rules")
    func conventionalRulesAreNotLinted() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        let source = "public struct One\n{\n}\npublic struct Two\n{\n}\n"
        try fixture.write("Sources/Example/Several.swift", source)
        try fixture.write("README.md", "fixture prose")
        #expect(try fixture.violations().isEmpty)
    }

    @Test("unreadable Swift is an operational failure")
    func invalidSourceIsNotTreatedAsEmpty() throws
    {
        let fixture = try PackageFixture()
        defer
        {
            fixture.remove()
        }
        let file = fixture.root.appendingPathComponent(
            "Sources/Example/Invalid.swift"
        )
        try FileManager.default.createDirectory(
            at: file.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data([0xFF]).write(to: file)
        #expect(throws: CocoaError.self)
        {
            try fixture.violations()
        }
    }
}
