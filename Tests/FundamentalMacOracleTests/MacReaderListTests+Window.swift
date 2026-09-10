import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderListTests
{
    @Test("native list groups preserve source through mouse selection and copy",
          arguments: SemanticListKind.allCases, [360.0, 820.0])
    func window(kind: SemanticListKind, width: Double) throws
    {
        let texts = [
            "", "e\u{301} 👩🏽‍💻 Հայերեն Раздел", "\n",
            "First line\nSecond line",
            "Readable source continues across several visual lines."
        ]
        let source = try MacReaderDocumentFixture.source(texts.map
        {
            MacReaderListFixture.block(kind, $0)
        })
        let retained = source
        let controller = try MacReaderDocumentFixture.window(
            source, width: width, height: 760
        )
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let groups = try MacReaderListFixture.groups(controller.readerView)
        try #require(groups.count == texts.count)
        try MacReaderDocumentFixture.capture(
            controller, name: "lists-\(kind)-\(Int(width))"
        )
        for (index, group) in groups.enumerated()
        {
            let label = kind == .bulleted ? "•" : "\(index + 1)."
            try MacReaderListFixture.expectGroup(
                group, text: texts[index], index: index, label: label
            )
            let block = source.document.content.blocks[index]
            if !texts[index].isEmpty
            {
                let selection = try MacReaderDocumentFixture.copy(
                    blockID: block.blockID.value, from: controller
                )
                #expect(selection.text.utf16.elementsEqual(texts[index].utf16))
                #expect(selection.sourceSlices.allSatisfy
                {
                    $0.source.domain == .block(block.blockID.value)
                })
            }
        }
        #expect(source == retained)
    }
}
