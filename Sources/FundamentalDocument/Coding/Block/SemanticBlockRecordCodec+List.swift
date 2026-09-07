extension SemanticBlockRecordCodec
{
    static func decodeList(
        _ object: [String: Any], runs: [SemanticRun], path: [String]
    ) throws -> SemanticBlock
    {
        let reader = SemanticTableRecordCodec.self
        let value = try reader.string(
            reader.required("listKind", in: object, path: path),
            path: path + ["listKind"]
        )
        guard let kind = SemanticListKind(rawValue: value)
        else
        {
            throw reader.invalid(path + ["listKind"], "Unknown list kind")
        }
        return .listItem(SemanticListItem(kind: kind, runs: runs))
    }
}
