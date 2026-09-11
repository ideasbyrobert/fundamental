import CryptoKit
import Foundation

package struct PatternResource: Codable, Sendable
{
    package let locale: String
    package let filename: String
    package let sourceFilename: String
    package let revision: String
    package let sourceSHA256: String
    package let sha256: String
    package let left: Int
    package let right: Int
    package let license: String

    package func load(from directory: URL) throws -> PatternData
    {
        let url = directory.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try decode(data)
    }

    package func decode(_ data: Data) throws(PatternFailure) -> PatternData
    {
        guard Self.digest(data) == sha256
        else
        {
            throw .checksumMismatch
        }
        guard let source = String(data: data, encoding: .utf8)
        else
        {
            throw .invalidEncoding
        }
        return try PatternData(source)
    }

    package func dictionary(from directory: URL) throws -> PatternDictionary
    {
        try PatternDictionary(
            identity: locale + "@" + revision + ":" + sha256,
            data: load(from: directory),
            minima: PatternMinima(left: left, right: right)
        )
    }

    package static func digest(_ data: Data) -> String
    {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
