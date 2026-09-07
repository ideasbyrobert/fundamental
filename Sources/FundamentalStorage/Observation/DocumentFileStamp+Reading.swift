import Darwin

extension DocumentFileStamp
{
    init(descriptor: Int32) throws
    {
        var value = stat()
        guard fstat(descriptor, &value) == 0
        else
        {
            throw DocumentFileFailure.fileSystem(errno)
        }
        try self.init(value)
    }

    init(location: DocumentFileLocation) throws
    {
        var value = stat()
        guard lstat(location.path, &value) == 0
        else
        {
            throw DocumentFileFailure.fileSystem(errno)
        }
        try self.init(value)
    }
}
