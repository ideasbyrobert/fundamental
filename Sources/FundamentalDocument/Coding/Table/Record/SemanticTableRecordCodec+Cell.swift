extension SemanticTableRecordCodec
{
    static func decodeCell(
        _ value: Any,
        path: [String]
    ) throws -> SemanticTableCell
    {
        let object = try object(value, path: path)
        let kindPath = path + ["kind"]
        let kind = try string(
            required("kind", in: object, path: path),
            path: kindPath
        )
        let alignmentPath = path + ["alignment"]
        let alignmentValue = try string(
            required("alignment", in: object, path: path),
            path: alignmentPath
        )
        guard let alignment = SemanticTableColumnAlignment(
            rawValue: alignmentValue
        )
        else
        {
            throw invalid(alignmentPath, "Unknown alignment")
        }
        let runs = try decodeRuns(
            required("runs", in: object, path: path),
            path: path + ["runs"]
        )

        switch kind
        {
        case "regular":
            try requireKeys(
                object,
                ["alignment", "kind", "runs"],
                path: path
            )
            return .regular(RegularSemanticTableCell(
                runs: runs,
                alignment: alignment
            ))
        case "spanning":
            try requireKeys(
                object,
                ["alignment", "extent", "kind", "runs"],
                path: path
            )
            let extent = try decodeExtent(
                required("extent", in: object, path: path),
                path: path + ["extent"]
            )
            return .spanning(SpanningSemanticTableCell(
                runs: runs,
                alignment: alignment,
                extent: extent
            ))
        default:
            throw invalid(kindPath, "Unknown cell tag")
        }
    }

    static func decodeExtent(
        _ value: Any,
        path: [String]
    ) throws -> SemanticTableCellExtent
    {
        let object = try object(value, path: path)
        try requireKeys(object, ["columns", "rows"], path: path)
        let rows = try integer(
            required("rows", in: object, path: path),
            path: path + ["rows"]
        )
        let columns = try integer(
            required("columns", in: object, path: path),
            path: path + ["columns"]
        )
        guard let extent = SemanticTableCellExtent(
            rowCount: rows,
            columnCount: columns
        )
        else
        {
            throw invalid(path, "Invalid spanning extent")
        }
        return extent
    }

    static func encodeCell(
        _ cell: SemanticTableCell,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )
        try container.encode(
            cell.alignment.rawValue,
            forKey: key("alignment")
        )
        var runs = container.nestedUnkeyedContainer(
            forKey: key("runs")
        )
        try encodeRuns(cell.runs, to: &runs)

        switch cell
        {
        case .regular:
            try container.encode("regular", forKey: key("kind"))
        case let .spanning(cell):
            try container.encode("spanning", forKey: key("kind"))
            let extentEncoder = container.superEncoder(
                forKey: key("extent")
            )
            try encodeExtent(cell.extent, to: extentEncoder)
        }
    }

    static func encodeExtent(
        _ extent: SemanticTableCellExtent,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )
        try container.encode(
            extent.columnCount,
            forKey: key("columns")
        )
        try container.encode(extent.rowCount, forKey: key("rows"))
    }
}
