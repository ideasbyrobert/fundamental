import Foundation

extension ApplicationBundle
{
    func sign(_ bundle: URL, arguments: [String]) throws
    {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        process.arguments = arguments + [bundle.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0
        else
        {
            throw CocoaError(.executableRuntimeMismatch)
        }
    }
}
