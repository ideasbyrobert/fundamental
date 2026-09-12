import Foundation

@MainActor
struct WritingZoomPreferences
{
    static let key = "FundamentalWritingZoomPercentage"
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard)
    {
        self.defaults = defaults
    }

    var zoom: WritingZoom
    {
        WritingZoom(defaults.integer(forKey: Self.key))
    }

    func store(_ zoom: WritingZoom)
    {
        defaults.set(zoom.percentage, forKey: Self.key)
    }
}
