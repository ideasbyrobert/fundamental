import Foundation
import FundamentalDocument
import Testing

@testable import FundamentalStorage

final class DocumentFileFixture
{
    static let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
    let root: URL

    init() throws
    {
        root = FileManager.default.temporaryDirectory
            .appending(path: "FundamentalStorage-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )
    }

    deinit
    {
        try? FileManager.default.removeItem(at: root)
    }

    func location(_ name: String = "Witness.fundamental") throws
        -> DocumentFileLocation
    {
        try #require(DocumentFileLocation(root.appending(path: name)))
    }

    func write(
        _ bytes: Data = record,
        name: String = "Witness.fundamental"
    ) throws -> DocumentFileLocation
    {
        let location = try location(name)
        try bytes.write(to: location.url, options: .withoutOverwriting)
        return location
    }

    static var record: Data
    {
        Data(("""
        {
          "blocks": [{
            "blockID": "00000000-0000-0000-0000-000000000002",
            "content": {
              "kind": "paragraph",
              "runs": [{"text": "e\\u0301 Հայ 👩‍💻", "traits": []}]
            }
          }],
          "documentID": "00000000-0000-0000-0000-000000000001",
          "format": "fundamental-document",
          "revision": 9007199254740993,
          "version": 1
        }
        """ + "\n").utf8)
    }
}
