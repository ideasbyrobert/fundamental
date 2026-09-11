import Foundation

struct WritingUIBuild
{
    let source: URL
    let evidence: URL

    func prepare() throws
    {
        let steps = [
            ("writer", ["swift", "build", "--product", "Fundamental"]),
            ("bundler", ["swift", "build", "--product", "bundle"]),
            ("source", ["git", "rev-parse", "HEAD"]),
            ("changes", ["git", "diff", "--binary", "HEAD"]),
            ("status", ["git", "status", "--porcelain"])
        ]
        for (name, arguments) in steps
        {
            try WritingUICommand(
                executable: URL(fileURLWithPath: "/usr/bin/xcrun"),
                arguments: arguments
            ).run(in: source, log: evidence.appending(path: name + ".log"))
        }
        let snapshot = evidence.appending(path: "source-snapshot")
        let manager = FileManager.default
        try manager.createDirectory(at: snapshot,
                                      withIntermediateDirectories: false)
        for name in ["Package.swift", "Sources", "Tests", "Tools"]
        {
            try manager.copyItem(at: source.appending(path: name),
                                 to: snapshot.appending(path: name))
        }
        try nativeTestHost()
        try bundle()
    }
}
