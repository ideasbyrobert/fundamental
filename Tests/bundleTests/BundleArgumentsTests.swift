import Foundation
import Testing

@testable import bundle

@Suite("Bundle command arguments")
struct BundleArgumentsTests
{
    let base = ["bundle", "/tmp/program", "/tmp/Example.app"]

    @Test
    func existingInvocationKeepsItsDefaultVersion() throws
    {
        let value = try BundleArguments(base).application
        #expect(value.version == "1")
        #expect(value.resources.isEmpty)
        #expect(value.executable.path == "/tmp/program")
        #expect(value.destination.path == "/tmp/Example.app")
    }

    @Test(arguments: ["1", "1.2", "1.2.3"])
    func explicitVersionsRemainValid(_ version: String) throws
    {
        #expect(try BundleArguments(base + [version])
            .application.version == version)
    }

    @Test(arguments: [false, true])
    func resourcePathsPreserveSpacesAndOrder(_ explicit: Bool) throws
    {
        let version = explicit ? ["2.3"] : []
        let paths = ["/tmp/One Words.bundle", "/tmp/Two.bundle"]
        let options = paths.flatMap { ["--resource", $0] }
        let value = try BundleArguments(base + version + options).application
        #expect(value.resources.map(\.path) == paths)
        #expect(value.version == (explicit ? "2.3" : "1"))
    }

    @Test(arguments: ["", "x", "-1", "1.", ".1", "1..2", "1.2.3.4"])
    func invalidVersionsAreRefused(_ version: String)
    {
        #expect(throws: CocoaError.self)
        {
            try BundleArguments(base + [version])
        }
    }

    @Test(arguments: [
        ["bundle"], ["bundle", "/tmp/program"],
        ["bundle", "/tmp/program", "/tmp/App.app", "--resource"],
        ["bundle", "/tmp/program", "/tmp/App.app", "1", "--resource"],
        ["bundle", "/tmp/program", "/tmp/App.app", "1", "--unknown", "a"]
    ])
    func malformedArgumentsAreRefused(_ arguments: [String])
    {
        #expect(throws: CocoaError.self)
        {
            try BundleArguments(arguments)
        }
    }
}
