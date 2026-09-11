struct MarkedWordGroup
{
    let range: Range<Int>
    let marks: [SourceHyphenationMark]
    let resolution: WordScopeResolution
}
