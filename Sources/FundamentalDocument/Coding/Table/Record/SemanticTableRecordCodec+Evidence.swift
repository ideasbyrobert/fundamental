extension SemanticTableRecordCodec
{
    static func decodeEvidence(
        _ value: Any,
        path: [String]
    ) throws -> SemanticTableEvidence
    {
        let values = try array(value, path: path)
        let facts = try values.enumerated().map
        {
            try decodeEvidenceFact(
                $0.element,
                path: path + [String($0.offset)]
            )
        }
        guard let firstFact = facts.first,
              let evidence = SemanticTableEvidence(
                  firstFact: firstFact,
                  remainingFacts: Array(facts.dropFirst())
              )
        else
        {
            throw invalid(path, "Evidence must be nonempty and consistent")
        }
        return evidence
    }

    static func decodeEvidenceFact(
        _ value: Any,
        path: [String]
    ) throws -> SemanticTableEvidenceFact
    {
        let object = try object(value, path: path)
        let kindPath = path + ["kind"]
        let kind = try string(
            required("kind", in: object, path: path),
            path: kindPath
        )

        switch kind
        {
        case "sourceLocation":
            try requireKeys(
                object,
                ["kind", "location", "target"],
                path: path
            )
            let target = try decodeEvidenceTarget(
                required("target", in: object, path: path),
                path: path + ["target"]
            )
            let locationPath = path + ["location"]
            let locationValue = try string(
                required("location", in: object, path: path),
                path: locationPath
            )
            guard let location = SemanticTableSourceLocation(
                locationValue
            )
            else
            {
                throw invalid(locationPath, "Location must not be blank")
            }
            return .sourceLocation(
                target: target,
                location: location
            )
        case "confidence":
            try requireKeys(
                object,
                ["confidence", "kind", "target"],
                path: path
            )
            let target = try decodeConfidenceTarget(
                required("target", in: object, path: path),
                path: path + ["target"]
            )
            let confidencePath = path + ["confidence"]
            let confidenceValue = try number(
                required("confidence", in: object, path: path),
                path: confidencePath
            )
            guard let confidence = SemanticTableConfidence(
                confidenceValue
            )
            else
            {
                throw invalid(confidencePath, "Invalid confidence")
            }
            return .confidence(
                target: target,
                confidence: confidence
            )
        case "repair":
            try requireKeys(
                object,
                ["kind", "repair", "target"],
                path: path
            )
            let target = try decodeEvidenceTarget(
                required("target", in: object, path: path),
                path: path + ["target"]
            )
            let repairPath = path + ["repair"]
            let repairValue = try string(
                required("repair", in: object, path: path),
                path: repairPath
            )
            guard let kind = SemanticTableRepairKind(
                rawValue: repairValue
            ),
            let repair = SemanticTableRepair(
                target: target,
                kind: kind
            )
            else
            {
                throw invalid(repairPath, "Invalid repair")
            }
            return .repair(repair)
        default:
            throw invalid(kindPath, "Unknown evidence tag")
        }
    }

    static func decodeEvidenceTarget(
        _ value: Any,
        path: [String]
    ) throws -> SemanticTableEvidenceTarget
    {
        let object = try object(value, path: path)
        let kindPath = path + ["kind"]
        let kind = try string(
            required("kind", in: object, path: path),
            path: kindPath
        )

        switch kind
        {
        case "table":
            try requireKeys(object, ["kind"], path: path)
            return .table
        case "row":
            try requireKeys(object, ["kind", "row"], path: path)
            let rowPath = path + ["row"]
            let rowValue = try integer(
                required("row", in: object, path: path),
                path: rowPath
            )
            guard let row = SemanticTableRowIndex(rowValue)
            else
            {
                throw invalid(rowPath, "Invalid row index")
            }
            return .row(row)
        case "cell":
            try requireKeys(
                object,
                ["cell", "kind", "row"],
                path: path
            )
            let rowPath = path + ["row"]
            let cellPath = path + ["cell"]
            let rowValue = try integer(
                required("row", in: object, path: path),
                path: rowPath
            )
            let cellValue = try integer(
                required("cell", in: object, path: path),
                path: cellPath
            )
            guard let row = SemanticTableRowIndex(rowValue),
                  let cell = SemanticTableCellIndex(cellValue)
            else
            {
                throw invalid(path, "Invalid cell target")
            }
            return .cell(row: row, cell: cell)
        default:
            throw invalid(kindPath, "Unknown target tag")
        }
    }

    static func decodeConfidenceTarget(
        _ value: Any,
        path: [String]
    ) throws -> SemanticTableConfidenceTarget
    {
        let target = try decodeEvidenceTarget(value, path: path)
        switch target
        {
        case .table:
            return .table
        case let .cell(row, cell):
            return .cell(row: row, cell: cell)
        case .row:
            throw invalid(path, "Confidence cannot target a row")
        }
    }

    static func encodeEvidence(
        _ evidence: SemanticTableEvidence,
        to container: inout UnkeyedEncodingContainer
    ) throws
    {
        for fact in evidence.facts
        {
            try encodeEvidenceFact(
                fact,
                to: container.superEncoder()
            )
        }
    }

    static func encodeEvidenceFact(
        _ fact: SemanticTableEvidenceFact,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )

        switch fact
        {
        case let .sourceLocation(target, location):
            try container.encode(
                "sourceLocation",
                forKey: key("kind")
            )
            try container.encode(
                location.value,
                forKey: key("location")
            )
            let targetEncoder = container.superEncoder(
                forKey: key("target")
            )
            try encodeEvidenceTarget(target, to: targetEncoder)
        case let .confidence(target, confidence):
            try container.encode("confidence", forKey: key("kind"))
            try container.encode(
                confidence.value,
                forKey: key("confidence")
            )
            let targetEncoder = container.superEncoder(
                forKey: key("target")
            )
            try encodeConfidenceTarget(target, to: targetEncoder)
        case let .repair(repair):
            try container.encode("repair", forKey: key("kind"))
            try container.encode(
                repair.kind.rawValue,
                forKey: key("repair")
            )
            let targetEncoder = container.superEncoder(
                forKey: key("target")
            )
            try encodeEvidenceTarget(
                repair.target,
                to: targetEncoder
            )
        }
    }

    static func encodeEvidenceTarget(
        _ target: SemanticTableEvidenceTarget,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )
        switch target
        {
        case .table:
            try container.encode("table", forKey: key("kind"))
        case let .row(row):
            try container.encode("row", forKey: key("kind"))
            try container.encode(row.value, forKey: key("row"))
        case let .cell(row, cell):
            try container.encode("cell", forKey: key("kind"))
            try container.encode(row.value, forKey: key("row"))
            try container.encode(cell.value, forKey: key("cell"))
        }
    }

    static func encodeConfidenceTarget(
        _ target: SemanticTableConfidenceTarget,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )
        switch target
        {
        case .table:
            try container.encode("table", forKey: key("kind"))
        case let .cell(row, cell):
            try container.encode("cell", forKey: key("kind"))
            try container.encode(row.value, forKey: key("row"))
            try container.encode(cell.value, forKey: key("cell"))
        }
    }
}
