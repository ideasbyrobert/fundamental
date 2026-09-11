import Foundation
import Testing

@testable import bundle

@Suite("Application resource packaging")
struct BundleResourceTests
{
    @Test
    func existingExecutableOnlyBundleStillWorks() throws
    {
        let root = try BundleFixture.directory()
        defer
        {
            try? FileManager.default.removeItem(at: root)
        }
        let application = BundleFixture.application(root, resources: [])
        try application.write()
        #expect(FileManager.default.fileExists(
            atPath: application.destination.appending(
                path: "Contents/MacOS/Fundamental"
            ).path
        ))
        #expect(!FileManager.default.fileExists(
            atPath: application.destination.appending(
                path: "Contents/Resources"
            ).path
        ))
    }

    @Test
    func explicitResourceBytesSurvivePackaging() throws
    {
        let root = try BundleFixture.directory()
        defer
        {
            try? FileManager.default.removeItem(at: root)
        }
        let resource = try BundleFixture.resource(root)
        let application = BundleFixture.application(root, resources: [resource])
        try application.write()
        let relative = "Contents/Resources/words.patterns"
        let original = try Data(contentsOf: resource.appending(path: relative))
        let copied = application.destination.appending(
            path: "Contents/Resources/Words.bundle/" + relative
        )
        #expect(try Data(contentsOf: copied) == original)
        #expect(original == Data("район\r\ncafe\u{301}\n".utf8))
    }

    @Test
    func failedResourceAdmissionLeavesNoPublishedOrStagedApplication() throws
    {
        let root = try BundleFixture.directory()
        defer
        {
            try? FileManager.default.removeItem(at: root)
        }
        let resource = try BundleFixture.resource(root)
        let link = root.appending(path: "Link.bundle")
        try FileManager.default.createSymbolicLink(at: link,
                                                   withDestinationURL: resource)
        let cases = [
            [resource, resource], [root.appending(path: "Missing.bundle")],
            [link], [root]
        ]
        for resources in cases
        {
            let application = BundleFixture.application(
                root, resources: resources
            )
            #expect(throws: CocoaError.self)
            {
                try application.write()
            }
            let contents = try FileManager.default.contentsOfDirectory(
                atPath: root.path
            )
            #expect(!contents.contains { $0.hasSuffix(".app") })
        }
    }
}
