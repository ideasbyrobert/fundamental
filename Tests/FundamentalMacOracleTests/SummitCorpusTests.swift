import FundamentalPresentation
import Testing

@Suite("The deterministic macOS summit corpus")
@MainActor
struct SummitCorpusTests
{
    @Test("every heading level and text witness reaches presentation")
    func textualWitnessesReachPresentation() throws
    {
        let residents = try MacSummitScan().residents
        var levels = Set<Int>()
        var text = ""
        for resident in residents
        {
            switch resident.content
            {
            case let .section(level, line):
                levels.insert(level.rawValue)
                text += line.text
            case let .body(line),
                 let .title(line),
                 let .code(line),
                 let .caption(line):
                text += line.text
            case let .headerCell(_, _, .line(line)),
                 let .bodyCell(_, _, .line(line)):
                text += line.text
            default:
                break
            }
        }
        #expect(levels == Set(1 ... 6))
        #expect(text.contains("0123456789"))
        #expect(text.contains("cafe\u{301}"))
        #expect(text.contains("\u{0915}\u{093F}"))
        #expect(text.contains("مرحبا"))
        #expect(text.contains("שלום"))
        #expect(text.contains("\u{2708}\u{FE0F}"))
        #expect(text.contains("👍🏽"))
        #expect(text.contains("👩🏽‍💻"))
        #expect(text.contains("🇦🇲 🇺🇸"))
        #expect(text.contains("what is, is"))
        #expect(text.contains("func finite"))
    }
}
