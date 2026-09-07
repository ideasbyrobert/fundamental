package enum DocumentFileFailure: Error, Equatable
{
    case invalidLocation
    case fileSystem(Int32)
    case notRegularFile
    case changedDuringRead
    case coordinationUnavailable
}
