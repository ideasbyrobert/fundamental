import Foundation

struct WritingUILinkDocument
{
    let documentID = UUID()
    let blockID = UUID()
    let text = "Read this linked text e\u{301}😀"
    let link: String

    var expected: [[WritingUIScopeRun]]
    {
        [[WritingUIScopeRun(text, traits: ["strong"], link: link,
                            language: " en-GB ")]]
    }

    func write(to location: URL) throws
    {
        let run: [String: Any] = ["text": text, "traits": ["strong"],
                                 "link": link, "language": " en-GB "]
        let record: [String: Any] = [
            "format": "fundamental-document", "version": 1,
            "documentID": documentID.uuidString, "revision": 8,
            "blocks": [["blockID": blockID.uuidString,
                        "content": ["kind": "paragraph", "runs": [run]]]]
        ]
        let data = try JSONSerialization.data(withJSONObject: record,
                                               options: [.sortedKeys])
        try data.write(to: location, options: .withoutOverwriting)
    }
}
