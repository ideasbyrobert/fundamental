import Foundation

struct ApplicationBundle
{
    let executable: URL
    let destination: URL
    let version: String

    func write() throws
    {
        let manager = FileManager.default
        let values = try executable.resourceValues(forKeys: [.isRegularFileKey])
        guard values.isRegularFile == true,
              manager.isExecutableFile(atPath: executable.path),
              destination.pathExtension == "app"
        else
        {
            throw CocoaError(.fileReadInvalidFileName)
        }
        guard !manager.fileExists(atPath: destination.path)
        else
        {
            throw CocoaError(.fileWriteFileExists)
        }
        let parent = destination.deletingLastPathComponent()
        let staging = parent.appending(path: ".\(UUID()).app")
        try manager.createDirectory(at: staging,
                                    withIntermediateDirectories: false)
        defer
        {
            try? manager.removeItem(at: staging)
        }
        let contents = staging.appending(path: "Contents")
        let binaries = contents.appending(path: "MacOS")
        try manager.createDirectory(at: binaries,
                                    withIntermediateDirectories: true)
        try manager.copyItem(at: executable,
                             to: binaries.appending(path: "Fundamental"))
        let data = try PropertyListSerialization.data(
            fromPropertyList: information, format: .xml, options: 0
        )
        try data.write(to: contents.appending(path: "Info.plist"))
        try sign(staging, arguments: ["--force", "--sign", "-"])
        try sign(staging, arguments: ["--verify", "--strict"])
        try manager.moveItem(at: staging, to: destination)
    }
}
