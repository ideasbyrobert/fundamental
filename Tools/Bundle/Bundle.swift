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
        guard arguments.count >= 3
        else
        {
            print("Usage: bundle executable destination.app [build-version] "
                + "[--resource path.bundle]...")
            throw CocoaError(.fileReadInvalidFileName)
        }
        let bundle = try BundleArguments(arguments).application
        try bundle.write()
        print(bundle.destination.path)
    }
}
