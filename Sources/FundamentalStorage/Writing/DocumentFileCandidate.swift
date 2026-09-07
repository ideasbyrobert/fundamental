import Foundation

final class DocumentFileCandidate
{
    let directory: URL
    let url: URL
    var backupURL: URL?
    var preserved = false

    init(bytes: Data, destination: DocumentFileLocation) throws
    {
        let manager = FileManager.default
        directory = try manager.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: destination.url,
            create: true
        )
        url = directory.appending(path: "Pending.fundamental")
        do
        {
            try bytes.write(to: url, options: .withoutOverwriting)
            try manager.setAttributes(
                [.posixPermissions: 0o600], ofItemAtPath: url.path
            )
            let handle = try FileHandle(forWritingTo: url)
            defer
            {
                try? handle.close()
            }
            try handle.synchronize()
        }
        catch
        {
            try? manager.removeItem(at: directory)
            throw error
        }
    }

    deinit
    {
        if !preserved
        {
            _ = discard()
        }
    }
}
