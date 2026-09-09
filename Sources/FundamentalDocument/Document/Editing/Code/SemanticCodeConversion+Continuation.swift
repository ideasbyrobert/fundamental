extension SemanticCodeConversion
{
    package static func proseContinuationCount(
        in range: DocumentRange, of document: CanonicalDocument
    ) -> Int?
    {
        guard document.content.blocks.allSatisfy(
            { EditableSemanticBlock($0.block) != nil }
        ), let selection = SemanticBlockSelection(range: range, in: document)
        else
        {
            return nil
        }
        var count = 0
        for block in selection.blocks
        {
            guard case let .code(code) = block.block
            else
            {
                continue
            }
            let units = Array(code.runs.lazy.map(\.text).joined().utf16)
            let extra = CodeConversionLines.ranges(in: units).count - 1
            let (next, overflow) = count.addingReportingOverflow(extra)
            guard !overflow
            else
            {
                return nil
            }
            count = next
        }
        return count
    }
}
