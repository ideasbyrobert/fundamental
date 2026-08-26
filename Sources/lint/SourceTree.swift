import Foundation

struct SourceTree
{
    private let root: URL

    init(root: URL)
    {
        self.root = root
    }

    init?(containing path: String)
    {
        var candidate = URL(fileURLWithPath: path)
            .deletingLastPathComponent()
        while candidate.path != "/"
        {
            let manifest = candidate.appendingPathComponent("Package.swift")
            if FileManager.default.fileExists(atPath: manifest.path)
            {
                root = candidate
                return
            }
            candidate = candidate.deletingLastPathComponent()
        }
        return nil
    }

    func swiftFiles() throws -> [URL]
    {
        try files(under: root)
            .filter { $0.pathExtension == "swift" }
    }

    private func files(under directory: URL) throws -> [URL]
    {
        var traversalError: Error?
        let walker = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            errorHandler:
            {
                _, error in
                traversalError = error
                return false
            }
        )
        guard let walker
        else
        {
            throw CocoaError(
                .fileReadUnknown,
                userInfo: [NSFilePathErrorKey: directory.path]
            )
        }
        var found: [URL] = []
        while let file = walker.nextObject() as? URL
        {
            if file.pathComponents.contains(".build")
            {
                walker.skipDescendants()
                continue
            }
            if try Self.isPartOfPackage(file)
            {
                found.append(file)
            }
        }
        if let traversalError
        {
            throw traversalError
        }
        return found.sorted { $0.path < $1.path }
    }

    func location(of file: URL) -> String
    {
        let base = root.resolvingSymlinksInPath().path + "/"
        let path = file.resolvingSymlinksInPath().path
        guard path.hasPrefix(base)
        else
        {
            return path
        }
        return String(path.dropFirst(base.count))
    }

    func lines(of file: URL) throws -> [SourceLine]
    {
        let text = try String(contentsOf: file, encoding: .utf8)
        return SourceLine.lines(in: text)
    }

    private static func isPartOfPackage(_ url: URL) throws -> Bool
    {
        let regular = try url.resourceValues(
            forKeys: [.isRegularFileKey]
        ).isRegularFile
        return regular == true && !url.pathComponents.contains(".build")
    }

}
