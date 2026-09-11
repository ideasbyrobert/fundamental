import AppKit
import Testing

@main
@MainActor
struct NativeTestHost
{
    static func main()
    {
        do
        {
            guard let path = ProcessInfo.processInfo.environment[
                "NATIVE_TEST_BUNDLE"
            ], URL(fileURLWithPath: path).pathExtension == "xctest",
                  let bundle = Bundle(path: path)
            else
            {
                throw CocoaError(.fileReadNoSuchFile)
            }
            try bundle.loadAndReturnError()
            let application = NSApplication.shared
            application.setActivationPolicy(.regular)
            Task
            {
                let status: CInt = await Testing.__swiftPMEntryPoint()
                exit(status)
            }
            application.run()
            throw CocoaError(.executableRuntimeMismatch)
        }
        catch
        {
            FileHandle.standardError.write(Data(
                "native-test-host: \(error.localizedDescription)\n".utf8
            ))
            exit(1)
        }
    }
}
