import CryptoKit
import Foundation

extension WritingUIBuild
{
    func bundle() throws
    {
        let application = evidence.appending(path: "Application.app")
        let executable = source.appending(path: ".build/debug/Fundamental")
        try WritingUICommand(
            executable: source.appending(path: ".build/debug/bundle"),
            arguments: [executable.path, application.path, "102"]
        ).run(in: source, log: evidence.appending(path: "bundle.log"))
        let location = application.appending(path: "Contents/Info.plist")
        let data = try Data(contentsOf: location)
        guard var info = try PropertyListSerialization.propertyList(
            from: data, options: [], format: nil
        ) as? [String: Any]
        else
        {
            throw CocoaError(.fileReadCorruptFile)
        }
        let identity = "com.ideasbyrobert.Fundamental.UITesting." +
            UUID().uuidString
        info["CFBundleIdentifier"] = identity
        info["CFBundleName"] = "Fundamental UI Study"
        info["CFBundleDisplayName"] = "Fundamental UI Study"
        try PropertyListSerialization.data(
            fromPropertyList: info, format: .xml, options: 0
        ).write(to: location, options: .atomic)
        for (name, arguments) in [
            ("sign", ["--force", "--sign", "-", application.path]),
            ("verify", ["--verify", "--strict", application.path])
        ]
        {
            try WritingUICommand(
                executable: URL(fileURLWithPath: "/usr/bin/codesign"),
                arguments: arguments
            ).run(in: source, log: evidence.appending(path: name + ".log"))
        }
        let binary = application.appending(path: "Contents/MacOS/Fundamental")
        let digest = SHA256.hash(data: try Data(contentsOf: binary))
            .map { String(format: "%02x", $0) }.joined()
        let record = ["application": application.path,
                      "identifier": identity, "executableSHA256": digest]
        try JSONSerialization.data(
            withJSONObject: record, options: [.prettyPrinted, .sortedKeys]
        ).write(to: evidence.appending(path: "application.json"))
    }
}
