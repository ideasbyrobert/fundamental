import Foundation

extension ApplicationBundle
{
    func copyResources(to contents: URL) throws
    {
        guard !resources.isEmpty
        else
        {
            return
        }
        let manager = FileManager.default
        let destination = contents.appending(path: "Resources")
        try manager.createDirectory(
            at: destination, withIntermediateDirectories: true
        )
        var names: Set<String> = []
        for resource in resources
        {
            let values = try resource.resourceValues(
                forKeys: [.isDirectoryKey, .isSymbolicLinkKey]
            )
            guard resource.pathExtension == "bundle",
                  values.isDirectory == true, values.isSymbolicLink == false,
                  names.insert(resource.lastPathComponent).inserted
            else
            {
                throw CocoaError(.fileReadInvalidFileName)
            }
            try manager.copyItem(
                at: resource,
                to: destination.appending(path: resource.lastPathComponent)
            )
        }
    }
}
