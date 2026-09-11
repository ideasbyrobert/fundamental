import Foundation

struct WritingUIScopeRun
{
    let text: String
    let traits: [String]
    let link: String?
    let language: String?

    init(
        _ text: String, traits: [String] = [], link: String? = nil,
        language: String? = nil
    )
    {
        self.text = text
        self.traits = traits
        self.link = link
        self.language = language
    }

    static func matches(_ actual: [WritingUIRecord.Run], _ expected: [Self])
        -> Bool
    {
        let received = actual.flatMap
        {
            run in run.text.utf16.map { ($0, run) }
        }
        let required = expected.flatMap
        {
            run in run.text.utf16.map { ($0, run) }
        }
        return received.count == required.count &&
            zip(received, required).allSatisfy
            {
                $0.0 == $1.0 && $1.1.matchesAttributes($0.1)
            }
    }

    private func matchesAttributes(_ run: WritingUIRecord.Run) -> Bool
    {
        run.traits.sorted() == traits.sorted() &&
            run.link.map { Array($0.utf16) } == link.map { Array($0.utf16) } &&
            run.language.map { Array($0.utf16) } ==
                language.map { Array($0.utf16) }
    }
}
