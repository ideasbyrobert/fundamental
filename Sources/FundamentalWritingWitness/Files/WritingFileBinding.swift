import FundamentalStorage

struct WritingFileBinding: Sendable
{
    let location: DocumentFileLocation
    let revision: DocumentFileRevision

    init(_ file: DocumentFileRead)
    {
        location = file.location
        revision = file.revision
    }
}
