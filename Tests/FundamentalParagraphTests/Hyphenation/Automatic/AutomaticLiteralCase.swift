@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
struct AutomaticLiteralCase
{
    let name: String
    let text: String
    let language: String
    let nativeLanguage: NativeWordLanguage
    let offsets: [Int]

    static let all: [AutomaticLiteralCase] = [
        .init(name: "english-us", text: "Extraordinary", language: "en_US",
              nativeLanguage: .english, offsets: [2, 5, 7, 9]),
        .init(name: "english-gb", text: "Extraordinary", language: "en_GB",
              nativeLanguage: .english, offsets: [2, 10]),
        .init(name: "russian-nfc", text: "район", language: "ru_RU",
              nativeLanguage: .russian, offsets: [3]),
        .init(name: "russian-nfd", text: "раи\u{306}он", language: "ru_RU",
              nativeLanguage: .russian, offsets: [4]),
        .init(name: "prefixed-nfc", text: "👩‍💻 район", language: "ru_RU",
              nativeLanguage: .russian, offsets: [9]),
        .init(name: "prefixed-nfd", text: "👩‍💻 раи\u{306}он", language: "ru_RU",
              nativeLanguage: .russian, offsets: [10])
    ]
}
