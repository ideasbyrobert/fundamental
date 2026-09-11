import AppKit
import Testing

@MainActor
@Suite(.serialized)
struct WritingAcceptanceTests
{
    @Test
    func completeWritingWorkflowPreservesOneCanonicalAuthority() throws
    {
        let scenario = try WritingAcceptanceScenario()
        defer
        {
            scenario.close()
        }
        try scenario.beginAndType()
        try scenario.replaceAndPaste()
        try scenario.copyAndDelete()
        try scenario.traverseHistory()
        try scenario.refuseThenBranch()
        try scenario.rebuildAndClose()
    }
}
