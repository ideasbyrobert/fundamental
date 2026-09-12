struct WritingZoom: Equatable, Sendable
{
    let percentage: Int

    init(_ percentage: Int = 100)
    {
        self.percentage = (50 ... 200).contains(percentage) &&
            percentage.isMultiple(of: 10) ? percentage : 100
    }

    var scale: Double { Double(percentage) / 100 }
    var canIncrease: Bool { percentage < 200 }
    var canDecrease: Bool { percentage > 50 }
    var increased: WritingZoom { WritingZoom(min(percentage + 10, 200)) }
    var decreased: WritingZoom { WritingZoom(max(percentage - 10, 50)) }
}
