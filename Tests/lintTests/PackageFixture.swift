import Foundation

@testable import lint

struct PackageFixture
{
    let root: URL

    init() throws
    {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("lint-" + UUID().uuidString)
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: true
        )
        try write("Package.swift", "// swift-tools-version: 6.4\n")
    }

    var tree: SourceTree
    {
        SourceTree(root: root)
    }

    func violations() throws -> [Violation]
    {
        try Inspector(tree: tree).violations()
    }

    func write(_ relative: String, _ text: String) throws
    {
        let file = root.appendingPathComponent(relative)
        try FileManager.default.createDirectory(
            at: file.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try text.write(to: file, atomically: true, encoding: .utf8)
    }

    func remove()
    {
        try? FileManager.default.removeItem(at: root)
    }
}
