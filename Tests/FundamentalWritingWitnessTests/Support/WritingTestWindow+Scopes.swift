import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingTestWindow
{
    func openScopeSheet(_ kind: WritingScopeKind, toolbar: Bool = false) throws
        -> WritingScopeSheet
    {
        if toolbar
        {
            let popup = controller.formatting.text
            let item = try #require(popup.itemArray.first
                { $0.identifier?.rawValue == kind.rawValue })
            popup.select(item)
            #expect(popup.sendAction(popup.action, to: popup.target))
        }
        else
        {
            let item = try formatChoice(kind.title + "…", group: "Text Style")
            #expect(controller.validateUserInterfaceItem(item))
            try performFormat(item)
        }
        return try #require(controller.scopeSheet)
    }

    func setScopeValue(_ value: String, in sheet: WritingScopeSheet)
    {
        sheet.field.stringValue = value
        sheet.controlTextDidChange(Notification(
            name: NSControl.textDidChangeNotification, object: sheet.field
        ))
    }

    func finishScopeSheet(
        _ sheet: WritingScopeSheet, response: NSApplication.ModalResponse
    ) async throws
    {
        controller.documentWindow.endSheet(sheet.alert.window,
                                             returnCode: response)
        let deadline = ContinuousClock.now.advanced(by: .seconds(2))
        while controller.scopeSheet != nil && ContinuousClock.now < deadline
        {
            try await Task.sleep(for: .milliseconds(10))
        }
        try #require(controller.scopeSheet == nil)
    }
}
