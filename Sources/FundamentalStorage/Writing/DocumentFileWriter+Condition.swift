import Darwin

extension DocumentFileWriter
{
    func requirePriorState() throws -> DocumentFileRead?
    {
        switch condition
        {
        case .absent:
            var value = stat()
            guard lstat(location.path, &value) != 0
            else
            {
                throw DocumentFileFailure.destinationExists
            }
            guard errno == ENOENT
            else
            {
                throw DocumentFileFailure.fileSystem(errno)
            }
            return nil
        case let .unchanged(expected):
            let current = try DocumentFileReader(
                location: location, codec: codec
            ).read()
            guard current.revision == expected
            else
            {
                throw DocumentFileFailure.conflictingRevision
            }
            guard current.document.documentID == document.documentID
            else
            {
                throw DocumentFileFailure.differentDocument
            }
            return current
        }
    }
}
