import Foundation

@main
enum Lint
{
    static func main()
    {
        let status = run(
            tree: SourceTree(containing: #filePath),
            output:
            {
                print($0)
            },
            failure:
            {
                let message = $0 + "\n"
                FileHandle.standardError.write(Data(message.utf8))
            }
        )
        exit(Int32(status))
    }

    static func run(
        tree: SourceTree?,
        output: (String) -> Void,
        failure: (String) -> Void
    ) -> Int
    {
        guard let tree
        else
        {
            failure("lint: no package found")
            return 2
        }
        let violations: [Violation]
        do
        {
            violations = try Inspector(tree: tree).violations()
        }
        catch
        {
            failure("lint: \(error.localizedDescription)")
            return 2
        }
        for violation in violations
        {
            output(violation.report)
        }
        if !violations.isEmpty
        {
            let plural = violations.count == 1 ? "" : "s"
            output("")
            output("\(violations.count) violation\(plural)")
        }
        return violations.isEmpty ? 0 : 1
    }
}
