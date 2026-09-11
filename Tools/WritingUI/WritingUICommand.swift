import Foundation

struct WritingUICommand
{
    let executable: URL
    let arguments: [String]

    func run(in source: URL, log: URL) throws
    {
        let manager = FileManager.default
        guard !manager.fileExists(atPath: log.path),
              manager.createFile(atPath: log.path, contents: nil)
        else
        {
            throw CocoaError(.fileWriteFileExists)
        }
        let output = try FileHandle(forWritingTo: log)
        defer
        {
            try? output.close()
        }
        let process = Process()
        process.currentDirectoryURL = source
        process.executableURL = executable
        process.arguments = arguments
        process.standardOutput = output
        process.standardError = output
        try process.run()
        process.waitUntilExit()
        guard process.terminationReason == .exit, process.terminationStatus == 0
        else
        {
            throw CocoaError(.executableRuntimeMismatch,
                             userInfo: [NSFilePathErrorKey: log.path])
        }
    }
}
