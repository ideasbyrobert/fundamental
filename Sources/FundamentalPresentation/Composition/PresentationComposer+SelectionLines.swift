extension PresentationComposer
{
    static func selectionLines(
        _ selection: PresentationTextSelection,
        document: PresentedDocument
    ) -> [PresentationSelectionLine]?
    {
        let residents = document.residents.all
        guard let span = PresentationSelectionSpan(
            selection, residents: residents
        )
        else
        {
            return nil
        }
        var lines: [PresentationSelectionLine] = []
        var precedingUpper: Int?
        for index in span.indices
        {
            guard let result = selectionLine(
                residents[index], span: span, index: index,
                precedingUpper: precedingUpper
            )
            else
            {
                return nil
            }
            if let line = result.line
            {
                lines.append(line)
            }
            precedingUpper = result.upper
        }
        return lines.isEmpty ? nil : lines
    }
}
