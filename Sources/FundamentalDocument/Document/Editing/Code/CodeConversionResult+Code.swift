extension CodeConversionResult
{
    static func join(
        _ blocks: [IdentifiedSemanticBlock],
        language: SemanticCodeLanguageIdentifier?
    ) -> CodeConversionResult?
    {
        guard let first = blocks.first
        else
        {
            return nil
        }
        var runs: [SemanticRun] = []
        var mappings: [CodeConversionPointMap] = []
        var count = 0
        var trailingCR = false
        for (index, block) in blocks.enumerated()
        {
            guard let editable = EditableSemanticBlock(block.block)
            else
            {
                return nil
            }
            let separator = index == 0 ? "" : trailingCR ? "\r\n" : "\n"
            let (start, seamOverflow) = count.addingReportingOverflow(
                separator.utf16.count
            )
            let length = editable.utf16Count
            let (end, overflow) = start.addingReportingOverflow(length)
            guard !seamOverflow, !overflow
            else
            {
                return nil
            }
            if !separator.isEmpty
            {
                runs.append(SemanticRun(text: separator))
            }
            runs += editable.runs
            mappings.append(CodeConversionPointMap(
                sourceBlockID: block.blockID, sourceRange: 0 ... length,
                blockID: first.blockID, offset: start
            ))
            count = end
            trailingCR = editable.runs.last(where: { !$0.text.isEmpty })?
                .text.unicodeScalars.last?.value == 0x0D
        }
        let code: SemanticCodeBlock
        if let language
        {
            code = .languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs, language: language
            ))
        }
        else
        {
            code = .plain(PlainSemanticCodeBlock(runs: runs))
        }
        return CodeConversionResult(
            blocks: [IdentifiedSemanticBlock(
                blockID: first.blockID, block: .code(code)
            )],
            mappings: mappings
        )
    }
}
