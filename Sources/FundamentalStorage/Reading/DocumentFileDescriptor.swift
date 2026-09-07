import Darwin

final class DocumentFileDescriptor
{
    let rawValue: Int32

    init(location: DocumentFileLocation) throws
    {
        let flags = O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK
        let opened = open(location.path, flags)
        guard opened >= 0
        else
        {
            throw DocumentFileFailure.fileSystem(errno)
        }
        rawValue = opened
    }

    deinit
    {
        close(rawValue)
    }
}
