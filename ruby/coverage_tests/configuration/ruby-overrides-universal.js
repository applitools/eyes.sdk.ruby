module.exports = {
    // selenium3 pass / 4 fail
    // CheckRegionBySelectorInFrameFullyOnFirefoxLegacy
    // 'check region by selector in frame fully on firefox legacy': {skip:true},
    // CheckWindowAfterManualScrollOnSafari11
    // 'check window after manual scroll on safari 11': {skip:true},
    // CheckWindowAfterManualScrollOnSafari12
    // selenium-4 caps: {browserName: "safari", browserVersion: '12', platformName: 'macOS 10.13', :"sauce:username" => "...", :"sauce:accessKey" => "..." },
    // 'check window after manual scroll on safari 12': {skip:true},

    // Shadow dom JS errors
    // CheckRegionByElementWithinShadowDomWithVg
    // 'check region by element within shadow dom with vg': {skip: true},
    // CheckRegionBySelectorWithinShadowDomWithVg
    // 'check region by selector within shadow dom with vg': {skip: true},

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
    // 'should handle check of stale element if selector is preserved': {skip: true},
    // ShouldHandleCheckOfStaleElementInFrameIfSelectorIsPreserved
    // 'should handle check of stale element in frame if selector is preserved': {skip: true},

    // CheckWindowOnMobileWebAndroid
    // 'check window on mobile web android': {skip: true},

    // ShouldBeEmptyIfPageDelayedBy1500
    'should be empty if page delayed by 1500': {skip: true},
    // AppiumIOSCheckFullyWindowWithScrollAndPageCoverage_Native
    // 'appium iOS check fully window with scroll and pageCoverage': {skip: true},
    // AppiumIOSCheckWindowRegionWithScrollAndPageCoverage_Native
    // 'appium iOS check window region with scroll and pageCoverage': {skip: true},

    // AppiumAndroidLandscapeModeCheckRegionOnAndroid10
    'appium android landscape mode check region on android 10': {skip: true},
    // AppiumAndroidLandscapeModeCheckRegionOnAndroid7
    'appium android landscape mode check region on android 7': {skip: true},
    // AppiumAndroidLandscapeModeCheckWindowOnAndroid10
    'appium android landscape mode check window on android 10': {skip: true},
    // AppiumAndroidLandscapeModeCheckWindowOnAndroid7
    'appium android landscape mode check window on android 7': {skip: true},
    // 'should work with beforeCaptureScreenshot hook': {skip: true},

    // pass on py

    // CheckWindowOnMobileWebIos
    // 'check window on mobile web ios': {skip: true},

    // need fix in TG

    // ShouldSendAgentRunId
    'should send agentRunId': {skip: true},

    // ShouldWaitBeforeCaptureWithBreakpointsInCheck
    // 'should waitBeforeCapture with breakpoints in check': {skip: true},
    // ShouldWaitBeforeCaptureWithBreakpointsInOpen
    // 'should waitBeforeCapture with breakpoints in open': {skip: true},
    // PageCoverageDataIsCorrect
    // 'pageCoverage data is correct': {skip: true},
    // PageCoverageDataIsCorrectWithVg
    // 'pageCoverage data is correct with vg': {skip: true},

    // ShouldAbortUnclosedTests
    'should abort unclosed tests': {skip: true},
    // ShouldAbortUnclosedTestsWithVg
    'should abort unclosed tests with vg': {skip: true},

    // ShouldReturnAbortedTestsInGetAllTestResults
    'should return aborted tests in getAllTestResults': {skip: true},
    // ShouldReturnAbortedTestsInGetAllTestResultsWithVg
    'should return aborted tests in getAllTestResults with vg': {skip: true},
    // ShouldReturnBrowserInfoInGetAllTestResults
    'should return browserInfo in getAllTestResults': {skip: true},

    // CheckRegionsByCoordinatesInFrameWithCssStitching
    // 'check regions by coordinates in frame with css stitching': {skip: true},
    // CheckRegionsByCoordinatesInOverflowedFrameWithScrollStitching
    // 'check regions by coordinates in overflowed frame with scroll stitching': {skip: true},
    // CheckRegionsByCoordinatesInFrameWithScrollStitching
    // 'check regions by coordinates in frame with scroll stitching': {skip: true},
    // CheckRegionsByCoordinatesInOverflowedFrameWithVg
    // 'check regions by coordinates in overflowed frame with vg': {skip: true},
    // CheckRegionsByCoordinatesInFrameWithVg
    // 'check regions by coordinates in frame with vg': {skip: true},
    // CheckRegionsByCoordinatesInOverflowedFrameWithCssStitching
    // 'check regions by coordinates in overflowed frame with css stitching': {skip: true},

    // AppiumIOSNavBarCheckRegion_Native
    // 'appium iOS nav bar check region': {skip: true},
    // ShouldExtractTextRegionsFromImage
    // 'should extract text regions from image': {skip: true},
    // ShouldExtractTextFromRegionsWithoutAHint
    // 'should extract text from regions without a hint': {skip: true},
    // ShouldAbortAfterClose
    'should abort after close': {skip: true},
    // ShouldSendCorrectIgnoreRegionIfPageScrolledBeforeCheckWithCssStitching update with server version
}
