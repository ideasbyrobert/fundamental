import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingTextInterchangeTests
{
    @Test("text files refuse directories, links and protected destinations")
    func fileLocations() async throws
    {
        let directory = try WritingRecoveryTests.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appending(path: "Original.txt")
        let link = directory.appending(path: "Alias.txt")
        let original = Data("Original".utf8)
        try original.write(to: file)
        try FileManager.default.createSymbolicLink(at: link,
                                                    withDestinationURL: file)
        let files = WritingTextFiles()
        for location in [directory, link]
        {
            await #expect(throws: WritingTextFailure.invalidLocation)
            {
                try await files.read(location)
            }
            await #expect(throws: WritingTextFailure.invalidLocation)
            {
                try await files.write(Data(), to: location, protecting: nil)
            }
        }
        await #expect(throws: WritingTextFailure.invalidLocation)
        {
            try await files.write(Data(), to: file, protecting: file)
        }
        #expect(try Data(contentsOf: file) == original)
    }

    @Test("text names and File actions expose the conversion boundary")
    func panelsAndMenus()
    {
        for (name, expected) in [
            ("", "Untitled.txt"), ("Draft.fun", "Draft.txt"),
            ("Draft.fundamental", "Draft.txt"), ("Draft.txt", "Draft.txt"),
            ("Draft.v1", "Draft.v1.txt")
        ]
        {
            #expect(WritingTextPanels.suggestedName(name) == expected)
        }
        let menu = WritingApplicationMenu.fileMenu()
        #expect(menu.item(withTitle: "Import Text…")?.action ==
            #selector(WritingApplicationDelegate.importText(_:)))
        #expect(menu.item(withTitle: "Export Text…")?.action ==
            #selector(WritingWindowController.exportText(_:)))
    }
}
