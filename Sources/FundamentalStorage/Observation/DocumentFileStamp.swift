import Darwin

struct DocumentFileStamp: Equatable, Sendable
{
    let device: Int32
    let inode: UInt64
    let byteCount: Int64
    let modifiedSeconds: Int
    let modifiedNanoseconds: Int
    let changedSeconds: Int
    let changedNanoseconds: Int

    init(_ value: stat) throws
    {
        guard value.st_mode & S_IFMT == S_IFREG, value.st_size >= 0
        else
        {
            throw DocumentFileFailure.notRegularFile
        }
        device = value.st_dev
        inode = value.st_ino
        byteCount = value.st_size
        modifiedSeconds = value.st_mtimespec.tv_sec
        modifiedNanoseconds = value.st_mtimespec.tv_nsec
        changedSeconds = value.st_ctimespec.tv_sec
        changedNanoseconds = value.st_ctimespec.tv_nsec
    }
}
