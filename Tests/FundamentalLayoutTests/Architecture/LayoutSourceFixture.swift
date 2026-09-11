import Foundation

struct LayoutSourceFixture
{
    let root: URL

    init() throws
    {
        root = FileManager.default.temporaryDirectory
            .resolvingSymlinksInPath()
            .appendingPathComponent("LayoutSources-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )
    }

    var sources: LayoutArchitectureSources
    {
        LayoutArchitectureSources(directory: root)
    }

    func write(_ path: String, _ bytes: Data) throws
    {
        let url = root.appendingPathComponent(path)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try bytes.write(to: url)
    }

    func remove()
    {
        try? FileManager.default.removeItem(at: root)
    }
}
