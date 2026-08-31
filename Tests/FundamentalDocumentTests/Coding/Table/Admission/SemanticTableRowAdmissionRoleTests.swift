import Testing

@testable import FundamentalDocument

@Suite("A semantic table row admission role")
struct SemanticTableRowAdmissionRoleTests
{
    @Test("header and body are distinct instructions")
    func headerAndBodyAreDistinctInstructions()
    {
        #expect(SemanticTableRowAdmissionRole.header != .body)
    }

    @Test("both instructions form a closed exhaustive set")
    func bothInstructionsFormClosedExhaustiveSet()
    {
        let roles: [SemanticTableRowAdmissionRole] = [
            .header,
            .body
        ]
        let names = roles.map
        { role in
            switch role
            {
            case .header:
                "header"
            case .body:
                "body"
            }
        }

        #expect(names == ["header", "body"])
    }
}
