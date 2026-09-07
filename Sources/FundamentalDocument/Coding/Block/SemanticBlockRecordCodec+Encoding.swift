extension SemanticBlockRecordCodec
{
    static func encodeRecord(
        _ block: SemanticBlock,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(keyedBy: DocumentRecordCodingKey.self)
        switch block
        {
        case let .paragraph(paragraph):
            try encodeText("paragraph", paragraph.runs, to: &container)
        case let .heading(heading):
            switch heading
            {
            case let .title(title):
                try encodeText("title", title.runs, to: &container)
            case let .section(section):
                try encodeText("section", section.runs, to: &container)
                try container.encode(
                    section.level.rawValue,
                    forKey: DocumentRecordCodingKey("level")
                )
            }
        case let .code(code):
            switch code
            {
            case let .plain(plain):
                try encodeText("code", plain.runs, to: &container)
            case let .languageTagged(tagged):
                try encodeText("languageCode", tagged.runs, to: &container)
                try container.encode(
                    tagged.language.value,
                    forKey: DocumentRecordCodingKey("language")
                )
            }
        case let .table(record):
            try container.encode(
                "table",
                forKey: DocumentRecordCodingKey("kind")
            )
            let key = DocumentRecordCodingKey("table")
            try SemanticTableRecordCodec.encodeRecord(
                record,
                to: container.superEncoder(forKey: key)
            )
        }
    }

    private static func encodeText(
        _ kind: String,
        _ runs: [SemanticRun],
        to container: inout KeyedEncodingContainer<DocumentRecordCodingKey>
    ) throws
    {
        try container.encode(kind, forKey: DocumentRecordCodingKey("kind"))
        try container.encode(runs, forKey: DocumentRecordCodingKey("runs"))
    }
}
