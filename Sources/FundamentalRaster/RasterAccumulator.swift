struct RasterAccumulator
{
    let capacities: RasterCapacities
    var marks: [RasterMark] = []
    var regions: [RasterInteractionRegion] = []
    var glyphCount = 0
    var fillCount = 0
    var sourceSliceCount = 0
    var caretSiteCount = 0
    var fontVariationCount = 0
    var residentUTF16Count = 0
}
