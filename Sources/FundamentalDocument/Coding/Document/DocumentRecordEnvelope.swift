struct DocumentRecordEnvelope: Encodable
{
    static let format = "fundamental-document"
    static let version: UInt64 = 1

    private let document: CanonicalDocument

    init(_ document: CanonicalDocument)
    {
        self.document = document
    }

    func encode(to encoder: Encoder) throws
    {
        var root = encoder.container(keyedBy: DocumentRecordCodingKey.self)
        try root.encode(Self.format, forKey: DocumentRecordCodingKey("format"))
        try root.encode(
            document.content.blocks.contains(where:
                { if case .listItem = $0.block { true } else { false } }) ?
                2 : Self.version,
            forKey: DocumentRecordCodingKey("version")
        )
        try root.encode(
            document.documentID.value,
            forKey: DocumentRecordCodingKey("documentID")
        )
        try root.encode(
            document.revision.value,
            forKey: DocumentRecordCodingKey("revision")
        )
        var blocks = root.nestedUnkeyedContainer(
            forKey: DocumentRecordCodingKey("blocks")
        )
        for block in document.content.blocks
        {
            var entry = blocks.nestedContainer(
                keyedBy: DocumentRecordCodingKey.self
            )
            try entry.encode(
                block.blockID.value,
                forKey: DocumentRecordCodingKey("blockID")
            )
            let key = DocumentRecordCodingKey("content")
            try SemanticBlockRecordCodec.encodeRecord(
                block.block,
                to: entry.superEncoder(forKey: key)
            )
        }
    }
}
