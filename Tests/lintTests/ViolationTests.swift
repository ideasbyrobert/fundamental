import Testing

@testable import lint

@Suite("How a violation is reported")
struct ViolationTests
{
    @Test("the location is padded so rule names align")
    func locationIsPadded()
    {
        let violation = Violation(
            location: "Sources/Example/Value.swift",
            line: 7,
            rule: "width",
            detail: "81 columns"
        )
        let report = violation.report
        #expect(report.hasPrefix("Sources/Example/Value.swift:7"))
        #expect(report.hasSuffix("width  81 columns"))
        #expect(report.count == 44 + 1 + "width  81 columns".count)
    }

    @Test("a long Unicode location is never shortened")
    func unicodeLocationIsPreserved()
    {
        let location = String(repeating: "👩🏽‍💻", count: 10) + ".swift"
        let violation = Violation(
            location: location,
            line: 1,
            rule: "width",
            detail: "81 columns"
        )
        #expect(violation.report.hasPrefix(location + ":1 "))
    }
}
