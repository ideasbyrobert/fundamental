import CryptoKit
import Foundation

package struct DocumentFileRevision: Equatable, Sendable
{
    let stamp: DocumentFileStamp
    let digest: Data

    init(stamp: DocumentFileStamp, bytes: Data)
    {
        self.stamp = stamp
        digest = Data(SHA256.hash(data: bytes))
    }
}
