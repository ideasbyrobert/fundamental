import CryptoKit
import Foundation

extension WritingUIBuild
{
    func nativeTestBundle() throws
    {
        let application = evidence.appending(path: "NativeTestHost.app")
        let contents = application.appending(path: "Contents")
        let binaries = contents.appending(path: "MacOS")
        let executable = binaries.appending(path: "NativeTestHost")
        let manager = FileManager.default
        try manager.createDirectory(at: binaries,
                                      withIntermediateDirectories: true)
        try manager.copyItem(at: evidence.appending(path: "NativeTestHost"),
                             to: executable)
        let identity = "com.ideasbyrobert.Fundamental.NativeTests." +
            UUID().uuidString
        let info: [String: Any] = [
            "CFBundleIdentifier": identity,
            "CFBundleName": "Fundamental Native Tests",
            "CFBundleExecutable": "NativeTestHost",
            "CFBundlePackageType": "APPL",
            "NSHighResolutionCapable": true,
            "LSMinimumSystemVersion": "26.0"
        ]
        try PropertyListSerialization.data(
            fromPropertyList: info, format: .xml, options: 0
        ).write(to: contents.appending(path: "Info.plist"), options: .atomic)
        for (name, arguments) in [
            ("sign", ["--force", "--sign", "-", application.path]),
            ("verify", ["--verify", "--strict", application.path])
        ]
        {
            try WritingUICommand(
                executable: URL(fileURLWithPath: "/usr/bin/codesign"),
                arguments: arguments
            ).run(in: source, log: evidence.appending(
                path: "native-host-" + name + ".log"
            ))
        }
        let digest = SHA256.hash(data: try Data(contentsOf: executable))
            .map { String(format: "%02x", $0) }.joined()
        let record = ["application": application.path, "identifier": identity,
                      "executableSHA256": digest]
        try JSONSerialization.data(
            withJSONObject: record, options: [.prettyPrinted, .sortedKeys]
        ).write(to: evidence.appending(path: "native-host.json"))
    }
}
