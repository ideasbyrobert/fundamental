import Foundation

extension WritingUIBuild
{
    func nativeTestHost() throws
    {
        let platformLog = evidence.appending(path: "sdk-platform.log")
        let executable = URL(fileURLWithPath: "/usr/bin/xcrun")
        try WritingUICommand(
            executable: executable,
            arguments: ["--sdk", "macosx", "--show-sdk-platform-path"]
        ).run(in: source, log: platformLog)
        let path = try String(contentsOf: platformLog, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let platform = URL(fileURLWithPath: path)
        let frameworks = platform.appending(
            path: "Developer/Library/Frameworks"
        ).path
        let libraries = platform.appending(path: "Developer/usr/lib").path
        try WritingUICommand(executable: executable, arguments: [
            "swiftc", "-swift-version", "6", "-warnings-as-errors",
            "-parse-as-library", "-F", frameworks,
            "-Xlinker", "-rpath", "-Xlinker", frameworks,
            "-Xlinker", "-rpath", "-Xlinker", libraries,
            source.appending(
                path: "Tools/NativeTestHost/NativeTestHost.swift"
            ).path,
            "-o", evidence.appending(path: "NativeTestHost").path
        ]).run(in: source,
               log: evidence.appending(path: "native-test-host.log"))
    }
}
