extension DocumentFileReader
{
    func verify(byteCount: Int) throws
    {
        guard byteCount == initialStamp.byteCount,
              try DocumentFileStamp(descriptor: descriptor.rawValue)
                  == initialStamp,
              try DocumentFileStamp(location: location) == initialStamp
        else
        {
            throw DocumentFileFailure.changedDuringRead
        }
    }
}
