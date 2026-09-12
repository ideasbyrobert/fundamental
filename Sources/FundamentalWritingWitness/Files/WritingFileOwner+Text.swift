import Foundation
import FundamentalDocument

extension WritingFileOwner
{
    static func importText(
        _ location: URL, files: WritingTextFiles = .shared
    ) async throws -> WritingFileOwner
    {
        let imported = try await files.read(location)
        let owner = WritingFileOwner(
            session: DocumentSession(state: imported.state)
        )
        let name = location.deletingPathExtension().lastPathComponent
        owner.displayName = name.isEmpty ? "Untitled" : name
        return owner
    }

    func exportText(
        to location: URL, files: WritingTextFiles = .shared
    ) async throws
    {
        let data = try WritingTextExport.data(from: session.document)
        try await files.write(data, to: location,
                              protecting: binding?.location.url)
    }
}
