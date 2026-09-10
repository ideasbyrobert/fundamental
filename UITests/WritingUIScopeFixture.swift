import Foundation

struct WritingUIScopeFixture
{
    static let link = " https://example.invalid/e\u{301} "
    static let language = " ru-RU "
    let documentID = UUID()
    let blockIDs = (0 ..< 3).map { _ in UUID() }
    let texts = ["Link e\u{301} 😀", "Language русский", "Combined scope"]

    func write(to location: URL) throws
    {
        let blocks = texts.enumerated().map
        {
            index, text in
            var run: [String: Any] = ["text": text, "traits": [String]()]
            if index != 1
            {
                run["link"] = Self.link
            }
            if index != 0
            {
                run["language"] = Self.language
            }
            return ["blockID": blockIDs[index].uuidString,
                    "content": ["kind": "paragraph", "runs": [run]]]
                as [String: Any]
        }
        let record: [String: Any] = [
            "format": "fundamental-document", "version": 1,
            "documentID": documentID.uuidString, "revision": 8,
            "blocks": blocks
        ]
        let data = try JSONSerialization.data(withJSONObject: record,
                                               options: [.sortedKeys])
        try data.write(to: location, options: .withoutOverwriting)
    }
}
