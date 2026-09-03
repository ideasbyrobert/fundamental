@testable import FundamentalDocument

extension CanonicalSemanticTableRecordCodecTests
{
    static let tallEvidenceCell =
        #"{"alignment":"leading","extent":{"columns":1,"rows":2},"#
        + #""kind":"spanning","runs":[]}"#
    static let tallEvidenceRow = #"{"cells":[\#(tallEvidenceCell)]}"#
    static let emptyEvidenceRow = #"{"cells":[]}"#
    static let tallEvidenceContent =
        #"{"bodyRows":[\#(tallEvidenceRow),\#(emptyEvidenceRow)],"#
        + #""columnAlignments":[],"#
        + #""headerRows":[]}"#
    static let tallEvidenceTable =
        #"{"content":\#(tallEvidenceContent),"kind":"regular"}"#
    static let overreachingEvidenceContent =
        #"{"bodyRows":[\#(tallEvidenceRow)],"columnAlignments":[],"#
        + #""headerRows":[]}"#
    static let overreachingEvidenceTable =
        #"{"content":\#(overreachingEvidenceContent),"kind":"regular"}"#
}
