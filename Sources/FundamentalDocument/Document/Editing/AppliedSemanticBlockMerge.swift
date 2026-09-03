struct AppliedSemanticBlockMerge: Equatable, Sendable
{
    let document: CanonicalDocument
    let caret: ResolvedDocumentPoint

    init?(
        _ merge: SemanticBlockMerge,
        in source: CanonicalDocument
    )
    {
        let blocks = source.content.blocks
        guard Self.isEditable(source),
              merge.documentID == source.documentID,
              merge.revision == source.revision,
              let leadingIndex = blocks.firstIndex(where:
              {
                  $0.blockID == merge.leadingBlockID
              }),
              let trailingIndex = blocks.firstIndex(where:
              {
                  $0.blockID == merge.trailingBlockID
              }),
              trailingIndex == leadingIndex + 1,
              let leading = EditableSemanticBlock(
                blocks[leadingIndex].block
              ),
              let trailing = EditableSemanticBlock(
                blocks[trailingIndex].block
              ),
              let block = Self.merging(
                leading,
                with: trailing
              ),
              let seam = DocumentUTF16Offset(leading.utf16Count),
              let revision = DocumentRevision(after: source.revision),
              let document = Self.replacing(
                leadingAt: leadingIndex,
                trailingAt: trailingIndex,
                with: block,
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
            blockID: merge.leadingBlockID,
            utf16Offset: seam
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
}

private extension AppliedSemanticBlockMerge
{
    static func isEditable(_ document: CanonicalDocument) -> Bool
    {
        document.content.blocks.allSatisfy
        {
            EditableSemanticBlock($0.block) != nil
        }
    }

    static func merging(
        _ leading: EditableSemanticBlock,
        with trailing: EditableSemanticBlock
    ) -> SemanticBlock?
    {
        let runs = leading.runs + trailing.runs
        switch (leading, trailing)
        {
        case (.paragraph, .paragraph):
            return .paragraph(SemanticParagraph(runs: runs))
        case (.heading(.title), .heading(.title)):
            return .heading(.title(TitleSemanticHeading(runs: runs)))
        case let (
            .heading(.section(leadingHeading)),
            .heading(.section(trailingHeading))
        ):
            guard leadingHeading.level == trailingHeading.level
            else
            {
                return nil
            }
            return .heading(.section(SectionSemanticHeading(
                runs: runs,
                level: leadingHeading.level
            )))
        case (.code(.plain), .code(.plain)):
            return .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        case let (
            .code(.languageTagged(leadingCode)),
            .code(.languageTagged(trailingCode))
        ):
            guard leadingCode.language == trailingCode.language
            else
            {
                return nil
            }
            return .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs,
                language: leadingCode.language
            )))
        default:
            return nil
        }
    }

    static func replacing(
        leadingAt leadingIndex: Int,
        trailingAt trailingIndex: Int,
        with block: SemanticBlock,
        revision: DocumentRevision,
        in source: CanonicalDocument
    ) -> CanonicalDocument?
    {
        var blocks = source.content.blocks
        let leadingID = blocks[leadingIndex].blockID
        blocks[leadingIndex] = IdentifiedSemanticBlock(
            blockID: leadingID,
            block: block
        )
        blocks.remove(at: trailingIndex)

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
}
