extension SemanticBlockRecordCodec
{
    static func fields(
        for kind: String,
        path: [String]
    ) throws -> [String]
    {
        switch kind
        {
        case "paragraph", "title", "code":
            return ["kind", "runs"]
        case "section":
            return ["kind", "runs", "level"]
        case "listItem":
            return ["kind", "runs", "listKind"]
        case "languageCode":
            return ["kind", "runs", "language"]
        case "table":
            return ["kind", "table"]
        default:
            throw SemanticTableRecordCodec.invalid(
                path + ["kind"],
                "Unknown block kind"
            )
        }
    }
}
