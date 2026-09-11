import Foundation

@testable import bundle

enum BundleFixture
{
    static func directory() throws -> URL
    {
        let root = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(
            at: root, withIntermediateDirectories: false
        )
        return root
    }

    static func application(_ root: URL, resources: [URL]) -> ApplicationBundle
    {
        ApplicationBundle(
            executable: URL(fileURLWithPath: "/usr/bin/true"),
            destination: root.appending(path: "Example.app"),
            version: "1", resources: resources
        )
    }

    static func resource(_ root: URL) throws -> URL
    {
        let bundle = root.appending(path: "Words.bundle")
        let contents = bundle.appending(path: "Contents")
        let resources = contents.appending(path: "Resources")
        try FileManager.default.createDirectory(
            at: resources, withIntermediateDirectories: true
        )
        let information = [
            "CFBundleIdentifier": "com.example.WordResources",
            "CFBundleName": "Words", "CFBundlePackageType": "BNDL",
            "CFBundleVersion": "1"
        ]
        try PropertyListSerialization.data(
            fromPropertyList: information, format: .xml, options: 0
        ).write(to: contents.appending(path: "Info.plist"))
        try Data("район\r\ncafe\u{301}\n".utf8).write(
            to: resources.appending(path: "words.patterns")
        )
        return bundle
    }
}
