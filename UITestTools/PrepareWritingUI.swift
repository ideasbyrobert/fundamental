import Foundation

@main
enum PrepareWritingUI
{
    static func main()
    {
        do
        {
            guard CommandLine.arguments.count == 3
            else
            {
                throw CocoaError(.fileReadInvalidFileName)
            }
            let source = URL(fileURLWithPath: CommandLine.arguments[1])
                .standardizedFileURL
            let evidence = URL(fileURLWithPath: CommandLine.arguments[2])
                .standardizedFileURL
            let manager = FileManager.default
            guard manager.fileExists(atPath:
                source.appending(path: "Package.swift").path)
            else
            {
                throw CocoaError(.fileNoSuchFile)
            }
            guard !manager.fileExists(atPath: evidence.path)
            else
            {
                throw CocoaError(.fileWriteFileExists)
            }
            try manager.createDirectory(at: evidence,
                                          withIntermediateDirectories: true)
            try WritingUIBuild(source: source, evidence: evidence).prepare()
            print(evidence.appending(path: "Application.app").path)
        }
        catch
        {
            FileHandle.standardError.write(Data(
                "prepare-writing-ui: \(error.localizedDescription)\n".utf8
            ))
            exit(1)
        }
    }
}
