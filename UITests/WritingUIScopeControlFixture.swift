import Foundation

struct WritingUIScopeControlFixture
{
    static let outerLink = "https://example.invalid/é"
    static let innerLink = "https://example.invalid/e\u{301}"
    static let language = " ru-RU "
    static let changedLink = " https://example.invalid/e\u{301}😀 "
    static let changedLanguage = " en-GB "
    let documentID = UUID()
    let blockID = UUID()
    let texts = ["A", "e\u{301}😀", "Z"]

    func write(to location: URL) throws
    {
        let runs = texts.enumerated().map
        {
            index, text in
            ["text": text, "traits": ["strong"],
             "link": index == 1 ? Self.innerLink : Self.outerLink,
             "language": Self.language] as [String: Any]
        }
        let record: [String: Any] = [
            "format": "fundamental-document", "version": 1,
            "documentID": documentID.uuidString, "revision": 8,
            "blocks": [["blockID": blockID.uuidString,
                        "content": ["kind": "paragraph", "runs": runs]]]
        ]
        let data = try JSONSerialization.data(withJSONObject: record,
                                               options: [.sortedKeys])
        try data.write(to: location, options: .withoutOverwriting)
    }

    func expected(
        link: String? = Self.innerLink, language: String? = Self.language
    ) -> [[WritingUIScopeRun]]
    {
        [texts.enumerated().map
        {
            index, text in
            WritingUIScopeRun(text, traits: ["strong"],
                link: index == 1 ? link : Self.outerLink,
                language: index == 1 ? language : Self.language)
        }]
    }
}
