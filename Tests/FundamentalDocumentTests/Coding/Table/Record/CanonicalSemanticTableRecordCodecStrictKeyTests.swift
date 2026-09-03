import Foundation
import Testing

@testable import FundamentalDocument

extension CanonicalSemanticTableRecordCodecTests
{
    static let evidenceCell =
        #"{"alignment":"leading","kind":"regular","runs":[]}"#
    static let evidenceRow = #"{"cells":[\#(evidenceCell)]}"#
    static let evidenceContent =
        #"{"bodyRows":[\#(evidenceRow)],"columnAlignments":[],"headerRows":[]}"#
    static let evidenceTable =
        #"{"content":\#(evidenceContent),"kind":"regular"}"#
    static func sourcedRoot(
        _ evidence: String,
        table: String = evidenceTable
    ) -> String
    {
        #"{"evidence":[\#(evidence)],"record":"sourced","table":\#(table)}"#
    }
    static func fact(_ members: String, target: String) -> String
    {
        "{" + members + ",\"target\":" + target + "}"
    }
    static func invalidEvidenceTargetCases() -> [String]
    {
        let repair = #""kind":"repair","repair":"headerRowCountClamped""#
        let rows = [
            #"{"kind":"row"}"#,
            #"{"kind":"row","row":null}"#,
            #"{"kind":"row","row":"zero"}"#
        ]
        let cells = [
            #"{"kind":"cell","row":0}"#,
            #"{"cell":null,"kind":"cell","row":0}"#,
            #"{"cell":"zero","kind":"cell","row":0}"#
        ]
        return [
            "{" + repair + "}",
            "{" + repair + #", "target":null}"#,
            "{" + repair + #", "target":[]}"#
        ] + rows.map
        {
            fact(#""kind":"sourceLocation","location":"row""#, target: $0)
        } + cells.map
        {
            fact(#""confidence":1,"kind":"confidence""#, target: $0)
        }
    }
    @Test("unknown members at every canonical boundary refuse atomically")
    func unknownMembersAtEveryCanonicalBoundaryRefuseAtomically()
    {
        let run = #"{"text":"A","traits":[]}"#
        let extent = #"{"columns":2,"rows":1}"#
        let cell =
            #"{"alignment":"leading","extent":\#(extent),"#
            + #""kind":"spanning","runs":[\#(run)]}"#
        let row = #"{"cells":[\#(cell)]}"#
        let content =
            #"{"bodyRows":[\#(row)],"columnAlignments":[],"headerRows":[]}"#
        let table = #"{"content":\#(content),"kind":"regular"}"#
        let target = #"{"kind":"table"}"#
        let fact =
            #"{"confidence":1,"kind":"confidence","target":\#(target)}"#
        let root =
            #"{"evidence":[\#(fact)],"record":"sourced","table":\#(table)}"#
        let replacements = [
            (#"{"evidence""#, #"{"unknown":0,"evidence""#),
            (#""table":{"content""#, #""table":{"unknown":0,"content""#),
            (#""content":{"bodyRows""#, #""content":{"unknown":0,"bodyRows""#),
            (#""bodyRows":[{"cells""#, #""bodyRows":[{"unknown":0,"cells""#),
            (#""cells":[{"alignment""#, #""cells":[{"unknown":0,"alignment""#),
            (#""extent":{"columns""#, #""extent":{"unknown":0,"columns""#),
            (#""runs":[{"text""#, #""runs":[{"unknown":0,"text""#),
            (#""evidence":[{"confidence""#,
             #""evidence":[{"unknown":0,"confidence""#),
            (#""target":{"kind""#, #""target":{"unknown":0,"kind""#)
        ]
        for (member, replacement) in replacements
        {
            let json = root.replacingOccurrences(
                of: member,
                with: replacement
            )
            #expect(json != root)
            Self.expectRefusal(json)
        }
    }
}
