struct AppliedSemanticBlockSplit: Equatable, Sendable
{
    let document: CanonicalDocument
    let caret: ResolvedDocumentPoint

    init?(
        _ split: SemanticBlockSplit,
        in source: CanonicalDocument
    )
    {
        guard Self.isEditable(source),
              let point = ResolvedDocumentPoint(
                split.point,
                in: source
              ),
              !source.content.blocks.contains(where:
              {
                  $0.blockID == split.continuationBlockID
              }),
              let editableBlock = EditableSemanticBlock(
                source.content.blocks[point.blockIndex].block
              ),
              let partition = SemanticRunPartition(
                runs: editableBlock.runs,
                lowerBound: split.point.utf16Offset,
                upperBound: split.point.utf16Offset
              ),
              let revision = DocumentRevision(after: source.revision),
              let document = Self.splitting(
                blockAt: point.blockIndex,
                into: partition,
                continuationBlockID: split.continuationBlockID,
                revision: revision,
                in: source
              ),
              let zero = DocumentUTF16Offset(0)
        else
        {
            return nil
        }

        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: split.continuationBlockID,
            utf16Offset: zero
        )
        guard let caret = ResolvedDocumentPoint(
            candidate,
            in: document
        )
        else
        {
            return nil
        }

        self.document = document
        self.caret = caret
    }
}

private extension AppliedSemanticBlockSplit
{
    static func isEditable(_ document: CanonicalDocument) -> Bool
    {
        document.content.blocks.allSatisfy
        {
            EditableSemanticBlock($0.block) != nil
        }
    }

    static func splitting(
        blockAt index: Int,
        into partition: SemanticRunPartition,
        continuationBlockID: FundamentalBlockID,
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
                partition.prefix,
                in: editableBlock
            )
        )
        blocks.insert(
            IdentifiedSemanticBlock(
                blockID: continuationBlockID,
                block: Self.replacingRuns(
                    partition.suffix,
                    in: editableBlock
                )
            ),
            at: index + 1
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
