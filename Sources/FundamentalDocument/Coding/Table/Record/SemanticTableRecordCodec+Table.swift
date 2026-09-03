extension SemanticTableRecordCodec
{
    static func decodeTable(
        _ value: Any,
        path: [String]
    ) throws -> SemanticTable
    {
        let object = try object(value, path: path)
        let kindPath = path + ["kind"]
        let kind = try string(
            required("kind", in: object, path: path),
            path: kindPath
        )

        switch kind
        {
        case "regular":
            try requireKeys(
                object,
                ["content", "kind"],
                path: path
            )
            let content = try decodeContent(
                required("content", in: object, path: path),
                path: path + ["content"]
            )
            return .regular(RegularSemanticTable(content: content))
        case "captioned":
            try requireKeys(
                object,
                ["caption", "content", "kind"],
                path: path
            )
            let content = try decodeContent(
                required("content", in: object, path: path),
                path: path + ["content"]
            )
            let captionPath = path + ["caption"]
            let runs = try decodeRuns(
                required("caption", in: object, path: path),
                path: captionPath
            )
            guard let firstRun = runs.first
            else
            {
                throw invalid(captionPath, "Caption must not be empty")
            }
            let caption = SemanticTableCaption(
                firstRun: firstRun,
                remainingRuns: Array(runs.dropFirst())
            )
            return .captioned(CaptionedSemanticTable(
                content: content,
                caption: caption
            ))
        default:
            throw invalid(kindPath, "Unknown table tag")
        }
    }

    static func decodeContent(
        _ value: Any,
        path: [String]
    ) throws -> SemanticTableContent
    {
        let object = try object(value, path: path)
        try requireKeys(
            object,
            ["bodyRows", "columnAlignments", "headerRows"],
            path: path
        )

        let headerPath = path + ["headerRows"]
        let headerValues = try array(
            required("headerRows", in: object, path: path),
            path: headerPath
        )
        var headerRows: [HeaderSemanticTableRow] = []
        for (index, rowValue) in headerValues.enumerated()
        {
            let cells = try decodeRow(
                rowValue,
                path: headerPath + [String(index)]
            )
            headerRows.append(HeaderSemanticTableRow(cells: cells))
        }

        let bodyPath = path + ["bodyRows"]
        let bodyValues = try array(
            required("bodyRows", in: object, path: path),
            path: bodyPath
        )
        var bodyRows: [BodySemanticTableRow] = []
        for (index, rowValue) in bodyValues.enumerated()
        {
            let cells = try decodeRow(
                rowValue,
                path: bodyPath + [String(index)]
            )
            bodyRows.append(BodySemanticTableRow(cells: cells))
        }

        let alignmentPath = path + ["columnAlignments"]
        let alignmentValues = try array(
            required("columnAlignments", in: object, path: path),
            path: alignmentPath
        )
        var alignments: [SemanticTableColumnAlignment] = []
        for (index, alignmentValue) in alignmentValues.enumerated()
        {
            let valuePath = alignmentPath + [String(index)]
            let rawValue = try string(alignmentValue, path: valuePath)
            guard let alignment = SemanticTableColumnAlignment(
                rawValue: rawValue
            )
            else
            {
                throw invalid(valuePath, "Unknown alignment")
            }
            alignments.append(alignment)
        }

        guard let content = SemanticTableContent(
            headerRows: headerRows,
            bodyRows: bodyRows,
            columnAlignments: alignments
        )
        else
        {
            throw invalid(path, "A row span exceeds the table")
        }
        return content
    }

    static func decodeRow(
        _ value: Any,
        path: [String]
    ) throws -> [SemanticTableCell]
    {
        let object = try object(value, path: path)
        try requireKeys(object, ["cells"], path: path)
        let cellsPath = path + ["cells"]
        let values = try array(
            required("cells", in: object, path: path),
            path: cellsPath
        )
        return try values.enumerated().map
        {
            try decodeCell(
                $0.element,
                path: cellsPath + [String($0.offset)]
            )
        }
    }

    static func encodeTable(
        _ table: SemanticTable,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )

        switch table
        {
        case let .regular(table):
            try container.encode("regular", forKey: key("kind"))
            let contentEncoder = container.superEncoder(
                forKey: key("content")
            )
            try encodeContent(table.content, to: contentEncoder)
        case let .captioned(table):
            try container.encode("captioned", forKey: key("kind"))
            var caption = container.nestedUnkeyedContainer(
                forKey: key("caption")
            )
            try encodeRuns(table.caption.runs, to: &caption)
            let contentEncoder = container.superEncoder(
                forKey: key("content")
            )
            try encodeContent(table.content, to: contentEncoder)
        }
    }

    static func encodeContent(
        _ content: SemanticTableContent,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )
        var headerRows = container.nestedUnkeyedContainer(
            forKey: key("headerRows")
        )
        for row in content.headerRows
        {
            try encodeRow(row.cells, to: headerRows.superEncoder())
        }
        var bodyRows = container.nestedUnkeyedContainer(
            forKey: key("bodyRows")
        )
        for row in content.bodyRows
        {
            try encodeRow(row.cells, to: bodyRows.superEncoder())
        }
        try container.encode(
            content.columnAlignments.map(\.rawValue),
            forKey: key("columnAlignments")
        )
    }

    static func encodeRow(
        _ cells: [SemanticTableCell],
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )
        var values = container.nestedUnkeyedContainer(
            forKey: key("cells")
        )
        for cell in cells
        {
            try encodeCell(cell, to: values.superEncoder())
        }
    }
}
