import Foundation

extension SemanticTableRecordCodec
{
    static func decodeLegacy(
        _ data: Data
    ) throws -> SemanticTableRecord
    {
        let legacy = try JSONDecoder().decode(
            LegacySemanticTable.self,
            from: data
        )
        guard let admission = SemanticTableAdmissionAdapter.admit(legacy)
        else
        {
            throw invalid([], "Legacy table admission failed")
        }
        return admission.record
    }
}
