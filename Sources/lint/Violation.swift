struct Violation
{
    private let location: String
    let line: Int
    let rule: String
    private let detail: String

    init(
        location: String,
        line: Int,
        rule: String,
        detail: String
    )
    {
        self.location = location
        self.line = line
        self.rule = rule
        self.detail = detail
    }

    var report: String
    {
        let place = "\(location):\(line)"
        let spacing = String(
            repeating: " ",
            count: max(44 - place.count, 0) + 1
        )
        return "\(place)\(spacing)\(rule)  \(detail)"
    }
}
