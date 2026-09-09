import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingTestWindow
{
    func openLanguageSheet() throws -> WritingCodeLanguageSheet
    {
        let item = try formatChoice(WritingCodeLanguageMenu.title,
                                    group: "Paragraph Style")
        #expect(controller.validateUserInterfaceItem(item))
        try performFormat(item)
        return try #require(controller.codeLanguageSheet)
    }

    func setLanguage(_ value: String, in sheet: WritingCodeLanguageSheet)
    {
        sheet.field.stringValue = value
        sheet.controlTextDidChange(Notification(
            name: NSControl.textDidChangeNotification, object: sheet.field
        ))
    }

    func finishLanguageSheet(
        _ sheet: WritingCodeLanguageSheet,
        response: NSApplication.ModalResponse
    ) async throws
    {
        controller.documentWindow.endSheet(sheet.alert.window,
                                             returnCode: response)
        let deadline = ContinuousClock.now.advanced(by: .seconds(2))
        while controller.codeLanguageSheet != nil &&
            ContinuousClock.now < deadline
        {
            try await Task.sleep(for: .milliseconds(10))
        }
        try #require(controller.codeLanguageSheet == nil)
    }
}
