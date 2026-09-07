import Foundation
import FundamentalStorage
import Testing

struct WritingFileFixture
{
    let directory: URL
    let location: DocumentFileLocation

    init() throws
    {
        directory = FileManager.default.temporaryDirectory
            .appending(path: "FundamentalWriting-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )
        location = try #require(DocumentFileLocation(
            directory.appending(path: "Writing.fundamental")
        ))
    }

    func remove()
    {
        try? FileManager.default.removeItem(at: directory)
    }
}
