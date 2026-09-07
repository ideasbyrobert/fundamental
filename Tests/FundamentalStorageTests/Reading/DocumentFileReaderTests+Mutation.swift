import Darwin
import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalStorage

extension DocumentFileReaderTests
{
    @Test("in place changes after opening cannot become an admitted read")
    func modifiedAfterOpening() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let reader = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        )
        var bytes = DocumentFileFixture.record
        bytes[bytes.startIndex] = 0x20
        try bytes.write(to: location.url)
        #expect(throws: DocumentFileFailure.changedDuringRead)
        {
            try reader.read()
        }
    }

    @Test("replacement and removal after opening cannot retain the old path")
    func replacedAfterOpening() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let reader = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        )
        try DocumentFileFixture.record.write(to: location.url, options: .atomic)
        #expect(throws: DocumentFileFailure.changedDuringRead)
        {
            try reader.read()
        }
        let removed = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        )
        try FileManager.default.removeItem(at: location.url)
        #expect(throws: (any Error).self)
        {
            try removed.read()
        }
    }

    @Test("growth after admission stops at the declared byte boundary")
    func growthPastBound() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let limits = try #require(DocumentRecordLimits(
            maximumBytes: DocumentFileFixture.record.count, maximumBlocks: 1
        ))
        let reader = try DocumentFileReader(
            location: location, codec: DocumentRecordCodec(limits: limits)
        )
        var grown = DocumentFileFixture.record
        grown.append(0x20)
        try grown.write(to: location.url)
        #expect(throws: DocumentRecordFailure.byteLimitExceeded)
        {
            try reader.read()
        }
    }

    @Test("truncation after opening cannot publish the remaining prefix")
    func truncation() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let reader = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        )
        try Data().write(to: location.url)
        #expect(throws: DocumentFileFailure.changedDuringRead)
        {
            try reader.read()
        }
    }
}
