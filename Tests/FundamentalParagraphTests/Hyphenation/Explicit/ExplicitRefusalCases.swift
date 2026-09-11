@testable import FundamentalParagraph
enum ExplicitRefusalCases
{
    static let all: [ExplicitRefusalCase] = [
        .init("leading-soft", "\u{AD}abc", .nonAlphabeticContext),
        .init("trailing-soft", "abc\u{AD}", .nonAlphabeticContext),
        .init("leading-visible", "-abc", .nonAlphabeticContext),
        .init("trailing-visible", "abc-", .nonAlphabeticContext),
        .init("repeated-visible", "a--b", .nonAlphabeticContext),
        .init("repeated-soft", "a\u{AD}\u{AD}b", .nonAlphabeticContext),
        .init("numeric-left", "12-ab", .nonAlphabeticContext),
        .init("numeric-right", "ab-34", .nonAlphabeticContext),
        .init("number-pair", "12-34", .nonAlphabeticContext),
        .init("soft-numeric", "ab\u{AD}12", .nonAlphabeticContext),
        .init("combining-visible", "a-\u{301}b", .graphemeBoundary),
        .init("following-mark", "a\u{AD}\u{301}b", .nonAlphabeticContext),
        .init("hard-before", "a\n\u{AD}b", .nonAlphabeticContext),
        .init("hard-after", "a\u{AD}\nb", .nonAlphabeticContext),
        .init("apostrophe", "can't", .notBreakMark),
        .init("nonbreaking-only", "a\u{2011}b", .notBreakMark)
    ]
}
