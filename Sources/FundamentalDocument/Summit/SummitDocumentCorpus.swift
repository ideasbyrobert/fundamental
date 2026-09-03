import Foundation

package struct SummitDocumentCorpus: Sendable
{
    package let snapshot: DocumentSnapshot

    package init?()
    {
        guard let language = SemanticCodeLanguageIdentifier("swift"),
              let span = SemanticTableCellExtent(
                  rowCount: 1,
                  columnCount: 2
              ),
              let content = Self.content(
                  language: language,
                  span: span
              )
        else
        {
            return nil
        }
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(Self.documentID),
            revision: DocumentRevision(1),
            content: content
        )
        snapshot = DocumentSnapshot(
            generation: SnapshotGeneration(1),
            document: document
        )
    }

    private static var documentID: UUID
    {
        UUID(uuid: (
            0x69, 0x20, 0x26, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 1
        ))
    }

    private static func content(
        language: SemanticCodeLanguageIdentifier,
        span: SemanticTableCellExtent
    ) -> CanonicalDocumentContent?
    {
        guard let tableBlocks = tableBlocks(span: span)
        else
        {
            return nil
        }
        let blocks = headingBlocks()
            + proseBlocks()
            + codeBlocks(language: language)
            + tableBlocks
        guard let first = blocks.first
        else
        {
            return nil
        }
        return CanonicalDocumentContent(
            firstBlock: first,
            remainingBlocks: Array(blocks.dropFirst())
        )
    }

    private static func headingBlocks() -> [IdentifiedSemanticBlock]
    {
        let title = SemanticBlock.heading(.title(TitleSemanticHeading(
            runs: [run("Fundamental")]
        )))
        let sections = SemanticHeadingLevel.allCases.map
        {
            level in
            SemanticBlock.heading(.section(SectionSemanticHeading(
                runs: [run("Section level \(level.rawValue)")],
                level: level
            )))
        }
        return identified([title] + sections, startingAt: 1)
    }

    private static func proseBlocks() -> [IdentifiedSemanticBlock]
    {
        let unicode = [
            "Numbers 0123456789; punctuation — ‘quoted’…",
            "Decomposed Latin: cafe\u{301}.",
            "Devanagari: \u{0915}\u{093F}. Arabic: مرحبا. "
                + "Hebrew: שלום.",
            "Variation: \u{2708}\u{FE0F}. Modifier: 👍🏽.",
            "Joined emoji: 👩🏽‍💻. Flags: 🇦🇲 🇺🇸."
        ].joined(separator: " ")
        let long = Array(
            repeating: "Readable prose remains exact across every screen.",
            count: 24
        ).joined(separator: " ")
        let paragraphs: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: [
                run(unicode),
                run(" Strong.", traits: [.strong]),
                run(" Emphasized.", traits: [.emphasis]),
                run(" Underlined.", traits: [.underline])
            ])),
            .paragraph(SemanticParagraph(runs: [run(long)])),
            .paragraph(SemanticParagraph(runs: [run(long)])),
            .paragraph(SemanticParagraph(runs: [run(long)]))
        ]
        return identified(paragraphs, startingAt: 8)
    }

    private static func codeBlocks(
        language: SemanticCodeLanguageIdentifier
    ) -> [IdentifiedSemanticBlock]
    {
        identified([
            .code(.plain(PlainSemanticCodeBlock(runs: [
                run("let truth = \"what is, is\"\nprint(truth)")
            ]))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [run("func finite() -> Int { 26 }")],
                language: language
            )))
        ], startingAt: 12)
    }

    private static func tableBlocks(
        span: SemanticTableCellExtent
    ) -> [IdentifiedSemanticBlock]?
    {
        let header = HeaderSemanticTableRow(cells: [
            regularCell("Stage"),
            regularCell("Mechanism"),
            regularCell("Law")
        ])
        let body = BodySemanticTableRow(cells: [
            .spanning(SpanningSemanticTableCell(
                runs: [run("Projection and layout")],
                alignment: .leading,
                extent: span
            )),
            .regular(RegularSemanticTableCell(
                runs: [],
                alignment: .leading
            ))
        ])
        guard let content = SemanticTableContent(
            headerRows: [header],
            bodyRows: [body],
            columnAlignments: [.leading, .center, .trailing]
        )
        else
        {
            return nil
        }
        let regular = SemanticTable.regular(
            RegularSemanticTable(content: content)
        )
        let caption = SemanticTableCaption(
            firstRun: run("The finite summit stages"),
            remainingRuns: []
        )
        let captioned = SemanticTable.captioned(
            CaptionedSemanticTable(
                content: content,
                caption: caption
            )
        )
        return identified([
            .table(.semantic(regular)),
            .table(.semantic(captioned))
        ], startingAt: 14)
    }

    private static func regularCell(
        _ text: String
    ) -> SemanticTableCell
    {
        .regular(RegularSemanticTableCell(
            runs: [run(text)],
            alignment: .leading
        ))
    }

    private static func run(
        _ text: String,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticRun
    {
        .direct(SemanticDirectRun(
            text: text,
            traits: traits
        ))
    }

    private static func identified(
        _ blocks: [SemanticBlock],
        startingAt ordinal: Int
    ) -> [IdentifiedSemanticBlock]
    {
        blocks.enumerated().map
        {
            index, block in
            IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(blockID(ordinal + index)),
                block: block
            )
        }
    }

    private static func blockID(_ ordinal: Int) -> UUID
    {
        UUID(uuid: (
            0x69, 0x20, 0x26, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            UInt8(ordinal / 256),
            UInt8(ordinal % 256)
        ))
    }
}
