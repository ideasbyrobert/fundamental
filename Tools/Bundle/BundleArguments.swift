import Foundation

struct BundleArguments
{
    let application: ApplicationBundle

    init(_ arguments: [String]) throws
    {
        guard arguments.count >= 3
        else
        {
            throw CocoaError(.fileReadInvalidFileName)
        }
        var cursor = 3
        let version: String
        if cursor < arguments.count, arguments[cursor] != "--resource"
        {
            version = arguments[cursor]
            cursor += 1
        }
        else
        {
            version = "1"
        }
        let parts = version.split(separator: ".",
                                  omittingEmptySubsequences: false)
        guard (1 ... 3).contains(parts.count), parts.allSatisfy(
            { !$0.isEmpty && $0.utf8.allSatisfy { (48 ... 57).contains($0) } }
        )
        else
        {
            throw CocoaError(.propertyListWriteInvalid)
        }
        var resources: [URL] = []
        while cursor < arguments.count
        {
            guard arguments[cursor] == "--resource",
                  cursor + 1 < arguments.count
            else
            {
                throw CocoaError(.fileReadInvalidFileName)
            }
            resources.append(URL(fileURLWithPath: arguments[cursor + 1])
                .standardizedFileURL)
            cursor += 2
        }
        application = ApplicationBundle(
            executable: URL(fileURLWithPath: arguments[1]).standardizedFileURL,
            destination: URL(fileURLWithPath: arguments[2]).standardizedFileURL,
            version: version, resources: resources
        )
    }
}
