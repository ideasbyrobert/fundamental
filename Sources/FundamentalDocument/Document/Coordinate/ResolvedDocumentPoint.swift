struct ResolvedDocumentPoint: Equatable, Sendable
{
    enum RunPosition: Equatable, Sendable
    {
        case noRuns
        case run(
            index: Int,
            utf16Offset: DocumentUTF16Offset
        )
    }

    let point: DocumentPoint
    let blockIndex: Int
    let runPosition: RunPosition

    init?(
        _ point: DocumentPoint,
        in document: CanonicalDocument
    )
    {
        guard point.documentID == document.documentID,
              point.revision == document.revision
        else
        {
            return nil
        }

        let blocks = document.content.blocks
        guard let blockIndex = blocks.firstIndex(
            where: { $0.blockID == point.blockID }
        ),
        let editableBlock = EditableSemanticBlock(
            blocks[blockIndex].block
        ),
        editableBlock.admitsCharacterBoundary(
            at: point.utf16Offset
        ),
        let runPosition = Self.runPosition(
            at: point.utf16Offset,
            in: editableBlock.runs
        )
        else
        {
            return nil
        }

        self.point = point
        self.blockIndex = blockIndex
        self.runPosition = runPosition
    }

    private static func runPosition(
        at offset: DocumentUTF16Offset,
        in runs: [SemanticRun]
    ) -> RunPosition?
    {
        guard !runs.isEmpty
        else
        {
            return offset.value == 0 ? .noRuns : nil
        }

        var remaining = offset.value
        for (index, run) in runs.enumerated()
        {
            let runCount = run.text.utf16.count
            if remaining <= runCount
            {
                guard let runOffset = DocumentUTF16Offset(remaining)
                else
                {
                    return nil
                }
                return .run(
                    index: index,
                    utf16Offset: runOffset
                )
            }
            remaining -= runCount
        }
        return nil
    }
}
