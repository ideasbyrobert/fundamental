import AppKit
import FundamentalNativeParagraph
import FundamentalParagraph
import Testing

@testable import FundamentalLayout

@MainActor
struct LayoutProseRefusalTests
{
    @Test func invalidWidthsFailBeforeSourceAndNativeWork() throws
    {
        let prose = LayoutProseFixture.prose([])
        for width in [Double.nan, .infinity, -.infinity, 0, -1]
        {
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try NativeProseComposition(
                    prose, width: width, font: .systemFont(ofSize: 18),
                    language: .english, defaultLanguage: ""
                )
            }
        }
    }

    @Test func anEmptyDefaultLanguageIsRefused() throws
    {
        for value in ["", " \t\n"]
        {
            #expect(throws: WordScopeFailure.invalidDefaultLanguage(value))
            {
                try NativeProseComposition(
                    LayoutProseFixture.prose([]), width: 100,
                    font: .systemFont(ofSize: 18),
                    language: .english, defaultLanguage: value
                )
            }
        }
    }
}
