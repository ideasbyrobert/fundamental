import Testing

@Suite
struct WritingNativeSourceTests
{
    @Test
    func bridgeCommandsUseTheRenderedObservationAndNativeVeto() throws
    {
        let base = "Sources/FundamentalWritingWitness/Input/"
        let files = [
            "WritingNativeBridge", "WritingNativeBridge+Input",
            "WritingNativeBridge+Selection", "WritingNativeBridge+Actions"
        ]
        let source = try files.map
        {
            try WritingTestRepository.source(base + $0 + ".swift")
        }.joined(separator: "\n")
        #expect(source.contains("observation: projection.observation"))
        #expect(!source.contains("session.observation"))
        #expect(!source.contains("registerUndo"))
        #expect(source.contains("session.submit(proposal.command)"))
        #expect(source.contains("view.setSelectedRange(next.selection)"))
    }

    @Test
    func nativeCompositionChoosesOnlyTextKitTwoWithoutNativeUndo() throws
    {
        let controller = try WritingTestRepository.source(
            "Sources/FundamentalWritingWitness/Window/" +
            "WritingWindowSurface.swift"
        )
        let configuration = try WritingTestRepository.source(
            "Sources/FundamentalWritingWitness/Projection/" +
            "WritingTextConfiguration.swift"
        )
        #expect(controller.contains("usingTextLayoutManager: true"))
        #expect(!controller.contains("usingTextLayoutManager: false"))
        #expect(configuration.contains("view.allowsUndo = false"))
        #expect(!configuration.contains("allowsUndo = true"))
    }
}
