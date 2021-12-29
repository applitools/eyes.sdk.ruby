module.exports = {
    //New test error
    // CheckRegionBySelectorInFrameFullyOnFirefoxLegacy
    'check region by selector in frame fully on firefox legacy': {skip:true},

    // Shadow dom JS errors
    // CheckRegionByElementWithinShadowDomWithVg
    'check region by element within shadow dom with vg': {skip: true},
    // CheckRegionBySelectorWithinShadowDomWithVg
    'check region by selector within shadow dom with vg': {skip: true},

    // Applitools::DiffsFoundError
    // CheckWindowFullyOnAndroidChromeEmulatorOnDesktopPage - to skip
    // 'check window fully on android chrome emulator on desktop page': {skip: true},
    // CheckRegionBySelectorFullyOnPageWithStickyHeaderWithScrollStitching - baseline need update
    // 'check region by selector fully on page with sticky header with scroll stitching': {skip: true},
    // CheckWindowFullyOnPageWithStickyHeaderWithScrollStitching - baseline need update
    // 'check window fully on page with sticky header with scroll stitching': {skip: true},
    // CheckRegionInFrameHiddenUnderTopBarFullyWithScrollStitching - generation need { type: :css, selector: 'body' }
    // 'check region in frame hidden under top bar fully with scroll stitching': {skip: true},

    // ShouldHandleCheckOfStaleElementIfSelectorIsPreserved
    'should handle check of stale element if selector is preserved': {skip: true},
    // ShouldHandleCheckOfStaleElementInFrameIfSelectorIsPreserved
    'should handle check of stale element in frame if selector is preserved': {skip: true},
}
