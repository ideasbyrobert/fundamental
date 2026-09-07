import AppKit
import FundamentalStorage
import UniformTypeIdentifiers

@MainActor
struct WritingFilePanels
{
    static let documentType = UTType(
        exportedAs: "com.ideasbyrobert.fundamental-document",
        conformingTo: .json
    )

    static func save(
        for window: NSWindow,
        name: String?
    ) async -> DocumentFileLocation?
    {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [documentType]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = name ?? "Untitled.fundamental"
        guard await panel.beginSheetModal(for: window) == .OK,
              let url = panel.url
        else
        {
            return nil
        }
        return DocumentFileLocation(url)
    }

    static func open(for window: NSWindow?) async -> DocumentFileLocation?
    {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [documentType]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        let result: NSApplication.ModalResponse
        if let window
        {
            result = await panel.beginSheetModal(for: window)
        }
        else
        {
            result = await panel.begin()
        }
        guard result == .OK, let url = panel.url
        else
        {
            return nil
        }
        return DocumentFileLocation(url)
    }
}
