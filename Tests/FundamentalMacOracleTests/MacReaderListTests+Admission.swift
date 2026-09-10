import Testing

@testable import FundamentalMacOracle

extension MacReaderListTests
{
    @Test("native resources refuse malformed generated marker associations",
          arguments: MacReaderListAdmissionFault.allCases)
    func malformedNativeMarker(fault: MacReaderListAdmissionFault) throws
    {
        let snapshot = try MacReaderListPixelFixture.snapshot(
            kind: .numbered, count: 2, scale: 1
        )
        let changed = try MacReaderListPixelFixture.corrupt(
            snapshot, fault: fault
        )
        let executor = MacRasterExecutor()
        #expect(executor.admit(changed) == nil)
        #expect(executor.admit(snapshot) != nil)
    }
}
