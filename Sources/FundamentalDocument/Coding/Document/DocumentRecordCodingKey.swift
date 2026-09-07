struct DocumentRecordCodingKey: CodingKey
{
    let stringValue: String

    var intValue: Int?
    {
        Int(stringValue)
    }

    init(_ value: String)
    {
        stringValue = value
    }

    init?(stringValue: String)
    {
        self.init(stringValue)
    }

    init?(intValue: Int)
    {
        self.init(String(intValue))
    }
}
