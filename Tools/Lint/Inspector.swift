import Foundation

struct Inspector
{
    private static let measure = 80

    private let tree: SourceTree

    init(tree: SourceTree)
    {
        self.tree = tree
    }

    func violations() throws -> [Violation]
    {
        try tree.swiftFiles().flatMap(inspect)
    }

    private func inspect(_ file: URL) throws -> [Violation]
    {
        let location = tree.location(of: file)
        return try tree.lines(of: file).flatMap
        {
            judge($0, at: location)
        }
    }

    private func judge(
        _ line: SourceLine,
        at location: String
    ) -> [Violation]
    {
        var found: [Violation] = []
        if line.opensBraceOnSameLine
        {
            found.append(
                Violation(
                    location: location,
                    line: line.number,
                    rule: "braces",
                    detail: "opening brace shares its line"
                )
            )
        }
        if line.carriesComment
        {
            found.append(
                Violation(
                    location: location,
                    line: line.number,
                    rule: "comments",
                    detail: "comment in code"
                )
            )
        }
        if line.width > Self.measure
        {
            found.append(
                Violation(
                    location: location,
                    line: line.number,
                    rule: "width",
                    detail: "\(line.width) columns"
                )
            )
        }
        return found
    }
}
