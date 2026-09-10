import Testing

@testable import FundamentalDocument

@Suite("Canonical block style forward mappings")
struct CanonicalBlockStyleMappingTests
{
    @Test("every style maps to its exact semantic triple")
    func mappingsAreExact()
    {
        let mappings: [
            (
                style: CanonicalBlockStyle,
                kind: SemanticBlockKind,
                level: Int?,
                role: SemanticRoleHint
            )
        ] = [
            (.title, .heading, 1, .title),
            (.heading1, .heading, 1, .heading1),
            (.heading, .heading, 2, .heading2),
            (.subheading, .heading, 3, .heading3),
            (.heading4, .heading, 4, .heading4),
            (.heading5, .heading, 5, .heading5),
            (.heading6, .heading, 6, .heading6),
            (.body, .paragraph, nil, .body),
            (.monostyled, .code, nil, .code),
            (.bulleted, .listItem, nil, .bullet),
            (.numbered, .listItem, nil, .numberedItem)
        ]
        let styles = CanonicalBlockStyle.allCases
        #expect(mappings.count == styles.count)
        for (style, mapping) in zip(styles, mappings)
        {
            #expect(style == mapping.style)
            #expect(style.semanticKind == mapping.kind)
            #expect(style.headingLevel == mapping.level)
            #expect(style.roleHint == mapping.role)
        }
    }
}
