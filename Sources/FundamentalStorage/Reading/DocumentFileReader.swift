import FundamentalDocument

struct DocumentFileReader
{
    let location: DocumentFileLocation
    let codec: DocumentRecordCodec
    let descriptor: DocumentFileDescriptor
    let initialStamp: DocumentFileStamp

    init(
        location: DocumentFileLocation,
        codec: DocumentRecordCodec
    ) throws
    {
        self.location = location
        self.codec = codec
        let opened = try DocumentFileDescriptor(location: location)
        let stamp = try DocumentFileStamp(descriptor: opened.rawValue)
        guard stamp.byteCount <= codec.limits.maximumBytes
        else
        {
            throw DocumentRecordFailure.byteLimitExceeded
        }
        descriptor = opened
        initialStamp = stamp
    }

    func read() throws -> DocumentFileRead
    {
        let bytes = try readBytes()
        try verify(byteCount: bytes.count)
        let result = DocumentFileRead(
            location: location,
            document: try codec.decode(bytes),
            revision: DocumentFileRevision(stamp: initialStamp, bytes: bytes)
        )
        try verify(byteCount: bytes.count)
        return result
    }
}
