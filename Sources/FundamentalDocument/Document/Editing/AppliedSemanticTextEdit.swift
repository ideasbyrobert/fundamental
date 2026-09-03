struct AppliedSemanticTextEdit: Equatable, Sendable
{
    let document: CanonicalDocument
    let caret: ResolvedDocumentPoint

    init?(
        _ insertion: SemanticTextInsertion,
        in source: CanonicalDocument
    )
    {
        guard Self.isEditable(source),
              let point = ResolvedDocumentPoint(
                insertion.point,
                in: source
              ),
              let editableBlock = EditableSemanticBlock(
                source.content.blocks[point.blockIndex].block
              ),
              Self.admits(
                insertion.insertion.text,
                in: editableBlock
              ),
              let partition = SemanticRunPartition(
                runs: editableBlock.runs,
                lowerBound: insertion.point.utf16Offset,
                upperBound: insertion.point.utf16Offset
              ),
              let revision = DocumentRevision(after: source.revision)
        else
        {
            return nil
        }

        let runs = partition.prefix
            + [insertion.insertion.run]
            + partition.suffix
        guard let document = Self.replacing(
            blockAt: point.blockIndex,
            with: runs,
            revision: revision,
            in: source
        )
        else
        {
            return nil
        }

        let addition = insertion.point.utf16Offset.value
            .addingReportingOverflow(insertion.insertion.text.utf16.count)
        guard !addition.overflow,
              let offset = DocumentUTF16Offset(addition.partialValue)
        else
        {
            return nil
        }
        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: insertion.point.blockID,
            utf16Offset: offset
        )
        guard let caret = ResolvedPostEditCaret(
            candidate: candidate,
            affinity: .following,
            in: document
        )
        else
        {
            return nil
        }

        self.document = document
        self.caret = caret.resolvedPoint
    }

    init?(
        _ deletion: SemanticTextDeletion,
        in source: CanonicalDocument
    )
    {
        guard Self.isEditable(source),
              let range = ResolvedDocumentDeletionRange(
                deletion.range,
                in: source
              ),
              let editableBlock = EditableSemanticBlock(
                source.content.blocks[range.blockIndex].block
              ),
              let partition = SemanticRunPartition(
                runs: editableBlock.runs,
                lowerBound: range.lowerUTF16Offset,
                upperBound: range.upperUTF16Offset
              ),
              let revision = DocumentRevision(after: source.revision)
        else
        {
            return nil
        }

        let runs = partition.prefix + partition.suffix
        guard let document = Self.replacing(
            blockAt: range.blockIndex,
            with: runs,
            revision: revision,
            in: source
        )
        else
        {
            return nil
        }

        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: deletion.range.start.blockID,
            utf16Offset: range.lowerUTF16Offset
        )
        guard let caret = ResolvedPostEditCaret(
            candidate: candidate,
            affinity: .preceding,
            in: document
        )
        else
        {
            return nil
        }

        self.document = document
        self.caret = caret.resolvedPoint
    }

    init?(
        _ replacement: SemanticTextReplacement,
        in source: CanonicalDocument
    )
    {
        guard Self.isEditable(source),
              let range = ResolvedDocumentDeletionRange(
                replacement.range,
                in: source
              ),
              let editableBlock = EditableSemanticBlock(
                source.content.blocks[range.blockIndex].block
              ),
              Self.admits(
                replacement.insertion.text,
                in: editableBlock
              ),
              let partition = SemanticRunPartition(
                runs: editableBlock.runs,
                lowerBound: range.lowerUTF16Offset,
                upperBound: range.upperUTF16Offset
              ),
              let revision = DocumentRevision(after: source.revision)
        else
        {
            return nil
        }

        let runs = partition.prefix
            + [replacement.insertion.run]
            + partition.suffix
        guard let document = Self.replacing(
            blockAt: range.blockIndex,
            with: runs,
            revision: revision,
            in: source
        )
        else
        {
            return nil
        }

        let addition = range.lowerUTF16Offset.value
            .addingReportingOverflow(replacement.insertion.text.utf16.count)
        guard !addition.overflow,
              let offset = DocumentUTF16Offset(addition.partialValue)
        else
        {
            return nil
        }
        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: replacement.range.start.blockID,
            utf16Offset: offset
        )
        guard let caret = ResolvedPostEditCaret(
            candidate: candidate,
            affinity: .following,
            in: document
        )
        else
        {
            return nil
        }

        self.document = document
        self.caret = caret.resolvedPoint
    }

    init?(
        _ edit: SemanticTextEdit,
        in source: CanonicalDocument
    )
    {
        switch edit
        {
        case let .insertion(insertion):
            self.init(insertion, in: source)
        case let .deletion(deletion):
            self.init(deletion, in: source)
        case let .replacement(replacement):
            self.init(replacement, in: source)
        }
    }
}

private extension AppliedSemanticTextEdit
{
    static func isEditable(_ document: CanonicalDocument) -> Bool
    {
        document.content.blocks.allSatisfy
        {
            EditableSemanticBlock($0.block) != nil
        }
    }

    static func admits(
        _ text: String,
        in block: EditableSemanticBlock
    ) -> Bool
    {
        switch block
        {
        case .code:
            true
        case .paragraph, .heading:
            !text.unicodeScalars.contains
            {
                $0.value == 0x0A || $0.value == 0x0D
            }
        }
    }

    static func replacing(
        blockAt index: Int,
        with runs: [SemanticRun],
        revision: DocumentRevision,
        in source: CanonicalDocument
    ) -> CanonicalDocument?
    {
        var blocks = source.content.blocks
        let identified = blocks[index]
        guard let editableBlock = EditableSemanticBlock(identified.block)
        else
        {
            return nil
        }
        blocks[index] = IdentifiedSemanticBlock(
            blockID: identified.blockID,
            block: Self.replacingRuns(
                runs,
                in: editableBlock
            )
        )
        guard let first = blocks.first,
              let content = CanonicalDocumentContent(
                firstBlock: first,
                remainingBlocks: Array(blocks.dropFirst())
              )
        else
        {
            return nil
        }
        return CanonicalDocument(
            documentID: source.documentID,
            revision: revision,
            content: content
        )
    }

    static func replacingRuns(
        _ runs: [SemanticRun],
        in block: EditableSemanticBlock
    ) -> SemanticBlock
    {
        switch block
        {
        case .paragraph:
            .paragraph(SemanticParagraph(runs: runs))
        case .heading(.title):
            .heading(.title(TitleSemanticHeading(runs: runs)))
        case let .heading(.section(heading)):
            .heading(.section(SectionSemanticHeading(
                runs: runs,
                level: heading.level
            )))
        case .code(.plain):
            .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        case let .code(.languageTagged(block)):
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs,
                language: block.language
            )))
        }
    }
}
