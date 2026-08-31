import Foundation
import Testing

@testable import FundamentalDocument

extension LegacySemanticTableRecordCodecTests
{
    @Test("invalid nested legacy value refuses the whole record")
    func invalidNestedLegacyValueRefusesWholeRecord()
    {
        let cell =
            #"{"alignment":"leading","columnSpan":1,"confidence":1,"# +
            #""isHeader":false,"rowSpan":1,"runs":[]}"#
        let row = #"{"cells":[\#(cell)]}"#
        let root =
            #"{"columnAlignments":[],"confidence":1,"headerRowCount":0,"# +
            #""rows":[\#(row)]}"#
        let mutations = [
            (#""rows":[\#(row)]"#, #""rows":null"#),
            (#","rows":[\#(row)]"#, ""),
            (#""headerRowCount":0"#, #""headerRowCount":"zero""#),
            (#""headerRowCount":0,"#, ""),
            (#""columnAlignments":[]"#, #""columnAlignments":null"#),
            (#""columnAlignments":[],"#, ""),
            (#""alignment":"leading""#, #""alignment":"future""#),
            (#""alignment":"leading","#, ""),
            (#""confidence":1,"headerRowCount""#,
             #""confidence":2,"headerRowCount""#),
            (#""confidence":1,"headerRowCount":"#,
             #""confidence":"one","headerRowCount":"#),
            (#","confidence":1,"headerRowCount":"#,
             #","headerRowCount":"#),
            (#""columnSpan":1"#, #""columnSpan":"one""#),
            (#""columnSpan":1,"#, ""),
            (#""confidence":1,"isHeader""#,
             #""confidence":2,"isHeader""#),
            (#","confidence":1,"isHeader":"#, #","isHeader":"#),
            (#""isHeader":false"#, #""isHeader":"false""#),
            (#""isHeader":false,"#, ""),
            (#""rowSpan":1"#, #""rowSpan":"one""#),
            (#""rowSpan":1,"#, ""),
            (#""runs":[]"#, #""runs":null"#),
            (#","runs":[]"#, "")
        ]

        for (member, replacement) in mutations
        {
            let invalid = root.replacingOccurrences(
                of: member,
                with: replacement
            )
            #expect(invalid != root)
            do
            {
                _ = try SemanticTableRecordCodec.decode(
                    Data(invalid.utf8)
                )
                Issue.record("Expected complete legacy refusal")
            }
            catch
            {
            }
        }
    }
}
