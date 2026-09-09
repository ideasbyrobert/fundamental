import AppKit

extension WritingWindowController
{
    var canChooseCodeLanguage: Bool
    {
        canFormatSelection &&
            WritingCodeLanguageRequest(in: bridge.projection) != nil
    }

    @objc func chooseCodeLanguage(_ sender: Any?)
    {
        guard canChooseCodeLanguage,
              let range = bridge.formattingRange(in: textView),
              let request = WritingCodeLanguageRequest(
                  in: bridge.projection, range: range
              )
        else
        {
            formatting.update(bridge.projection)
            return
        }
        formatting.update(bridge.projection)
        let sheet = WritingCodeLanguageSheet(value: request.value)
        codeLanguageSheet = sheet
        sheet.present(for: documentWindow)
        {
            [weak self] value in
            guard let self
            else
            {
                return
            }
            codeLanguageSheet = nil
            if let value, let command = request.command(setting: value)
            {
                bridge.submitFormatting(command, in: textView)
            }
            else
            {
                bridge.project(in: textView)
                documentWindow.makeFirstResponder(textView)
            }
        }
    }
}
