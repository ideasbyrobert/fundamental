@testable import FundamentalParagraph
enum ExplicitCases
{
    static let all = english + russian + mixed

    static let english: [ExplicitCase] = [
        .init("english-soft", "extra\u{AD}ordinary", "extraordinary", [
            .init(6, "extra‐", "ordinary", .conditionalHyphen)
        ]),
        .init("english-capitals", "EXTRA\u{AD}ORDINARY", "EXTRAORDINARY", [
            .init(6, "EXTRA‐", "ORDINARY", .conditionalHyphen)
        ]),
        .init("ascii-visible", "well-known", "well-known", [
            .init(5, "well-", "known", .existing)
        ]),
        .init("punctuated", "(extra\u{AD}ordinary!)", "(extraordinary!)", [
            .init(7, "(extra‐", "ordinary!)", .conditionalHyphen)
        ]),
        .init(
            "multiple-words", "first extra\u{AD}ordinary end",
            "first extraordinary end", [
                .init(12, "first extra‐", "ordinary end", .conditionalHyphen)
            ]
        )
    ]

    static let mixed: [ExplicitCase] = [
        .init("multiple-soft", "re\u{AD}pre\u{AD}sentation", "representation", [
            .init(3, "re‐", "presentation", .conditionalHyphen),
            .init(7, "repre‐", "sentation", .conditionalHyphen)
        ]),
        .init("mixed-marks", "co\u{AD}oper-ate", "cooper-ate", [
            .init(3, "co‐", "oper-ate", .conditionalHyphen),
            .init(8, "cooper-", "ate", .existing)
        ]),
        .init("empty", "", "", []),
        .init("plain", "nothing here", "nothing here", [])
    ]

    static let russian: [ExplicitCase] = [
        .init("russian-nfc", "👩‍💻 рай\u{AD}он", "👩‍💻 район", [
            .init(10, "👩‍💻 рай‐", "он", .conditionalHyphen)
        ], language: "ru_RU"),
        .init("russian-nfd", "👩‍💻 раи\u{306}\u{AD}он", "👩‍💻 раи\u{306}он", [
            .init(11, "👩‍💻 раи\u{306}‐", "он", .conditionalHyphen)
        ], language: "ru_RU"),
        .init("russian-visible", "серо‐синий", "серо‐синий", [
            .init(5, "серо‐", "синий", .existing)
        ], language: "ru_RU"),
        .init("russian-capitals", "ЮНЕ\u{AD}СКО", "ЮНЕСКО", [
            .init(4, "ЮНЕ‐", "СКО", .conditionalHyphen)
        ], language: "ru_RU")
    ]
}
