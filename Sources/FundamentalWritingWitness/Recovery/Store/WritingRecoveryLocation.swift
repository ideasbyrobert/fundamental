import Foundation

struct WritingRecoveryLocation
{
    static func directory(
        identifier: String? = Bundle.main.bundleIdentifier,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> URL
    {
        let identity = identifier ??
            "com.ideasbyrobert.Fundamental.Development"
        if identity.hasPrefix("com.ideasbyrobert.Fundamental.UITesting."),
           let path = environment["FUNDAMENTAL_UI_RECOVERY_DIRECTORY"],
           path.hasPrefix("/")
        {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return URL.applicationSupportDirectory
            .appending(component: identity)
            .appending(component: "Recovery", directoryHint: .isDirectory)
    }
}
