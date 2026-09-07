extension SemanticBlockRecordCodec
{
    static func decodeRecord(
        _ value: Any,
        path: [String]
    ) throws -> SemanticBlock
    {
        let reader = SemanticTableRecordCodec.self
        let object = try reader.object(value, path: path)
        let kind = try reader.string(
            reader.required("kind", in: object, path: path),
            path: path + ["kind"]
        )
        try reader.requireKeys(
            object,
            fields(for: kind, path: path),
            path: path
        )
        if kind == "table"
        {
            let tablePath = path + ["table"]
            return .table(try reader.decodeRecord(
                reader.object(
                    reader.required("table", in: object, path: path),
                    path: tablePath
                ),
                path: tablePath
            ))
        }
        let runs = try reader.decodeRuns(
            reader.required("runs", in: object, path: path),
            path: path + ["runs"]
        )
        switch kind
        {
        case "paragraph":
            return .paragraph(SemanticParagraph(runs: runs))
        case "title":
            return .heading(.title(TitleSemanticHeading(runs: runs)))
        case "section":
            let level = try reader.integer(
                reader.required("level", in: object, path: path),
                path: path + ["level"]
            )
            guard let admitted = SemanticHeadingLevel(rawValue: level)
            else
            {
                throw reader.invalid(path + ["level"], "Invalid heading level")
            }
            return .heading(.section(SectionSemanticHeading(
                runs: runs,
                level: admitted
            )))
        case "code":
            return .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        case "languageCode":
            let language = try reader.string(
                reader.required("language", in: object, path: path),
                path: path + ["language"]
            )
            guard let admitted = SemanticCodeLanguageIdentifier(language)
            else
            {
                throw reader.invalid(path + ["language"], "Blank code language")
            }
            return .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs,
                language: admitted
            )))
        default:
            throw reader.invalid(path + ["kind"], "Unknown block kind")
        }
    }
}
