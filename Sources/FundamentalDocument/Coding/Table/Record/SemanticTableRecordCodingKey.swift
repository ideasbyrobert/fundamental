struct SemanticTableRecordCodingKey: CodingKey
{
    let stringValue: String
    let intValue: Int?

    init(_ stringValue: String)
    {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(stringValue: String)
    {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int)
    {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}
