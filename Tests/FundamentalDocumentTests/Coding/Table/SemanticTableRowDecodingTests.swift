import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticTableRowTests
{
    @Test("absent and null source locations decode as nil")
    func absentAndNullSourceLocationsDecodeAsNil() throws
    {
        let absentLocation = Data(
            #"{"cells":[]}"#.utf8
        )
        let decodedAbsent = try JSONDecoder().decode(
            SemanticTableRow.self,
            from: absentLocation
        )

        #expect(decodedAbsent.cells.isEmpty)
        #expect(decodedAbsent.sourceLocation == nil)

        let nullLocation = Data(
            #"{"cells":[],"sourceLocation":null}"#.utf8
        )
        let decodedNull = try JSONDecoder().decode(
            SemanticTableRow.self,
            from: nullLocation
        )

        #expect(decodedNull.cells.isEmpty)
        #expect(decodedNull.sourceLocation == nil)
    }

    @Test("missing and null cells are refused")
    func missingAndNullCellsAreRefused()
    {
        let missingCells = Data(
            #"{"sourceLocation":"table:2"}"#.utf8
        )
        let nullCells = Data(
            #"{"cells":null}"#.utf8
        )

        for payload in [missingCells, nullCells]
        {
            #expect(throws: DecodingError.self)
            {
                try JSONDecoder().decode(
                    SemanticTableRow.self,
                    from: payload
                )
            }
        }
    }
}
