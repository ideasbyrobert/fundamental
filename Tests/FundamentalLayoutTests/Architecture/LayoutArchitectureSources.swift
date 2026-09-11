import Foundation

struct LayoutArchitectureSources
{
    let directory: URL

    private let keys: Set<URLResourceKey> = [
        .isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey
    ]

    func files() throws -> [URL]
    {
        let root = try directory.resourceValues(forKeys: keys)
        guard root.isDirectory == true, root.isSymbolicLink == false
        else
        {
            throw refusal(directory)
        }
        var pending = [directory]
        var found: [URL] = []
        while let current = pending.popLast()
        {
            let entries = try FileManager.default.contentsOfDirectory(
                at: current,
                includingPropertiesForKeys: Array(keys),
                options: []
            )
            for entry in entries
            {
                let values = try entry.resourceValues(forKeys: keys)
                guard values.isSymbolicLink == false
                else
                {
                    throw refusal(entry)
                }
                if values.isDirectory == true
                {
                    pending.append(entry)
                }
                else if values.isRegularFile == true
                {
                    if entry.pathExtension == "swift"
                    {
                        found.append(entry)
                    }
                }
                else
                {
                    throw refusal(entry)
                }
            }
        }
        return found.sorted { $0.path < $1.path }
    }

    func text(
        where includes: (String) -> Bool = { _ in true }
    ) throws -> String
    {
        try files().filter { includes($0.lastPathComponent) }.map
        {
            try String(contentsOf: $0, encoding: .utf8)
        }.joined()
    }

    private func refusal(_ url: URL) -> CocoaError
    {
        CocoaError(.fileReadUnknown, userInfo: [NSFilePathErrorKey: url.path])
    }
}
