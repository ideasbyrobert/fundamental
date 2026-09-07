import Darwin
import Foundation
import FundamentalDocument

extension DocumentFileReader
{
    func readBytes() throws -> Data
    {
        var bytes = Data()
        bytes.reserveCapacity(Int(initialStamp.byteCount))
        var chunk = [UInt8](repeating: 0, count: 64 * 1024)
        while true
        {
            let remaining = codec.limits.maximumBytes - bytes.count
            let count = remaining < chunk.count ? remaining + 1 : chunk.count
            let received = chunk.withUnsafeMutableBytes
            {
                Darwin.read(descriptor.rawValue, $0.baseAddress, count)
            }
            if received < 0
            {
                if errno == EINTR
                {
                    continue
                }
                throw DocumentFileFailure.fileSystem(errno)
            }
            if received == 0
            {
                return bytes
            }
            guard received <= remaining
            else
            {
                throw DocumentRecordFailure.byteLimitExceeded
            }
            bytes.append(contentsOf: chunk.prefix(received))
        }
    }
}
