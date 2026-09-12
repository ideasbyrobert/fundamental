import AppKit
import UniformTypeIdentifiers

@MainActor
struct WritingTextPanels
{
    static func open(for window: NSWindow?) async -> URL?
    {
        let panel = NSOpenPanel()
        panel.title = "Import Text"
        panel.prompt = "Import"
        panel.allowedContentTypes = [.plainText]
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
        return result == .OK ? panel.url : nil
    }

    static func save(for window: NSWindow, name: String) async -> URL?
    {
        let panel = NSSavePanel()
        panel.title = "Export Text"
        panel.prompt = "Export"
        panel.allowedContentTypes = [.utf8PlainText]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = suggestedName(name)
        let result = await panel.beginSheetModal(for: window)
        return result == .OK ? panel.url : nil
    }

    static func suggestedName(_ name: String) -> String
    {
        let path = name as NSString
        let known = ["fun", "fundamental", "txt"]
            .contains(path.pathExtension.lowercased())
        let base = known ? path.deletingPathExtension : name
        return (base.isEmpty ? "Untitled" : base) + ".txt"
    }
}
