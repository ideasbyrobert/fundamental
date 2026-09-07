import Foundation

@main
enum Bundle
{
    static func main()
    {
        do
        {
            try write()
        }
        catch
        {
            let message = "bundle: \(error.localizedDescription)\n"
            FileHandle.standardError.write(Data(message.utf8))
            exit(1)
        }
    }

    static func write() throws
    {
        let arguments = CommandLine.arguments
        guard (3 ... 4).contains(arguments.count)
        else
        {
            print("Usage: bundle executable destination.app [build-version]")
            throw CocoaError(.fileReadInvalidFileName)
        }
        let version = arguments.count == 4 ? arguments[3] : "1"
        let parts = version.split(separator: ".",
                                  omittingEmptySubsequences: false)
        guard (1 ... 3).contains(parts.count), parts.allSatisfy(
            { !$0.isEmpty && $0.utf8.allSatisfy { (48 ... 57).contains($0) } }
        )
        else
        {
            throw CocoaError(.propertyListWriteInvalid)
        }
        let bundle = ApplicationBundle(
            executable: URL(fileURLWithPath: arguments[1]).standardizedFileURL,
            destination: URL(fileURLWithPath: arguments[2]).standardizedFileURL,
            version: version
        )
        try bundle.write()
        print(bundle.destination.path)
    }
}
