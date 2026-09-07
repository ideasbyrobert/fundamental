import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticBlockRecordCodecTests
{
    @Test("unknown missing extra and ill typed members refuse whole records")
    func invalidShapesRefuse() throws
    {
        let values = [
            "[]", "{}", "null", "{", #"{"kind":"future","runs":[]}"#,
            #"{"kind":"paragraph"}"#,
            #"{"kind":"paragraph","runs":[],"level":1}"#,
            #"{"kind":"paragraph","runs":null}"#,
            #"{"kind":true,"runs":[]}"#,
            #"{"kind":"code","runs":[],"language":"swift"}"#,
            #"{"kind":"title","runs":[],"level":1}"#
        ]
        for value in values
        {
            #expect(throws: (any Error).self)
            {
                try SemanticBlockRecordCodec.decode(Data(value.utf8))
            }
        }
    }

    @Test("heading levels and code languages retain their admission rules")
    func invalidSpecificFieldsRefuse()
    {
        let levels = ["0", "7", "true", "1.5", "null", "\"2\""]
        let languages = ["null", "true", "7", "\"\"", "\"  \""]
        let values = levels.map
        {
            #"{"kind":"section","level":\#($0),"runs":[]}"#
        } + languages.map
        {
            #"{"kind":"languageCode","language":\#($0),"runs":[]}"#
        }
        for value in values
        {
            #expect(throws: (any Error).self)
            {
                try SemanticBlockRecordCodec.decode(Data(value.utf8))
            }
        }
    }

    @Test("table blocks refuse legacy repair payloads")
    func legacyTablePayloadRefuses()
    {
        let legacy = #"{"columnAlignments":[],"headerRowCount":0,"rows":[]}"#
        let value = #"{"kind":"table","table":\#(legacy)}"#
        #expect(throws: (any Error).self)
        {
            try SemanticBlockRecordCodec.decode(Data(value.utf8))
        }
    }
}
