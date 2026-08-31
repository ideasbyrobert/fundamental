extension SemanticTableRecordCodec
{
    static func decodeRecord(
        _ object: [String: Any],
        path: [String]
    ) throws -> SemanticTableRecord
    {
        let recordPath = path + ["record"]
        let tag = try string(
            required("record", in: object, path: path),
            path: recordPath
        )

        switch tag
        {
        case "semantic":
            try requireKeys(
                object,
                ["record", "table"],
                path: path
            )
            let table = try decodeTable(
                required("table", in: object, path: path),
                path: path + ["table"]
            )
            return .semantic(table)
        case "sourced":
            try requireKeys(
                object,
                ["evidence", "record", "table"],
                path: path
            )
            let table = try decodeTable(
                required("table", in: object, path: path),
                path: path + ["table"]
            )
            let evidence = try decodeEvidence(
                required("evidence", in: object, path: path),
                path: path + ["evidence"]
            )
            guard let sourced = SourcedSemanticTable(
                table: table,
                evidence: evidence
            )
            else
            {
                throw invalid(path, "Evidence does not describe the table")
            }
            return .sourced(sourced)
        default:
            throw invalid(recordPath, "Unknown record tag")
        }
    }

    static func encodeRecord(
        _ record: SemanticTableRecord,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )

        switch record
        {
        case let .semantic(table):
            try container.encode("semantic", forKey: key("record"))
            let tableEncoder = container.superEncoder(
                forKey: key("table")
            )
            try encodeTable(table, to: tableEncoder)
        case let .sourced(sourced):
            try container.encode("sourced", forKey: key("record"))
            var evidence = container.nestedUnkeyedContainer(
                forKey: key("evidence")
            )
            try encodeEvidence(sourced.evidence, to: &evidence)
            let tableEncoder = container.superEncoder(
                forKey: key("table")
            )
            try encodeTable(sourced.table, to: tableEncoder)
        }
    }
}
