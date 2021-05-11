module.exports = {
    'should extract text from regions': {skipEmit: true}, // Not implemented yet
    'should extract text regions from image': {skipEmit: true}, // Not implemented yet
    // Appium test need a lot of fixes before run
    'check region by native selector': {skipEmit: true},
    'appium android check window': {skipEmit: true},
    'appium android check region with ignore region': {skipEmit: true},
    'appium android check region': {config: {branchName: 'current_ruby'}},
    'appium iOS check window': {skipEmit: true},
    'appium iOS check region with ignore region': {skipEmit: true},
    'appium iOS check region': {skipEmit: true},

    // Visual locator not implemented feature
    'should find regions by visual locator': {skip: true},
    'should find regions by visual locator with vg': {skip: true},

    // Test results (instead of test results vg returns array of the tests results)
    'should return test results from close with failed vg test': {skip: true},
    'should return test results from close with passed vg test': {skip: true},

    // Should send dom if version 11 ( expected: "11.0.0" || got: "7.1.3")
    'should send dom of version 11': {skip: true},

    // dom location block
    'should send dom and location when check window': {skipEmit: true},
    'should send dom and location when check window with vg': {skipEmit: true},
    'should send dom and location when check window fully': {skipEmit: true},
    'should send dom and location when check window fully with vg': {skipEmit: true},
    'should send dom and location when check frame': {skipEmit: true},
    'should send dom and location when check frame fully': {skipEmit: true},
    'should send dom and location when check region by selector': {skipEmit: true},
    'should send dom and location when check region by selector with vg': {skipEmit: true},
    'should send dom and location when check region by selector fully': {skipEmit: true},
    'should send dom and location when check region by selector fully with vg': {skipEmit: true},
    'should send dom and location when check region by selector in frame': {skipEmit: true},
    'should send dom and location when check region by selector with custom scroll root': {skipEmit: true},
    'should send dom and location when check region by selector with custom scroll root with vg': {skipEmit: true},
    'should send dom and location when check region by selector fully with custom scroll root': {skipEmit: true},
    // Missing (Or I could find a scroll root option)
    'check region by selector in overflowed frame fully with css stitching': {skipEmit: true},
    'check region by selector in overflowed frame fully with scroll stitching': {skipEmit: true},
    'check regions by coordinates in frame with css stitching': {skipEmit: true},
    'check regions by coordinates in frame with scroll stitching': {skipEmit: true},
    'check regions by coordinates in frame with vg': {skipEmit: true},
    'check regions by coordinates in overflowed frame with css stitching': {skipEmit: true},
    'check regions by coordinates in overflowed frame with scroll stitching': {skipEmit: true},
    'check window fully with custom scroll root with css stitching': {skipEmit: true},
    'check window fully with custom scroll root with scroll stitching': {skipEmit: true},
    'check window fully with custom scroll root with vg': {skipEmit: true},
    'check window fully with wrong scroll root with css stitching': {skipEmit: true},
    'check window fully with wrong scroll root with scroll stitching': {skipEmit: true},
    'check window fully with wrong scroll root with vg': {skipEmit: true},
    'check window fully with fixed scroll root element': {skipEmit: true},
    'check modal region by selector fully with css stitching': {skipEmit: true},
    'check modal region by selector fully with scroll stitching': {skipEmit: true},
    'check scrollable modal region by selector fully with css stitching': {skipEmit: true},
    'check scrollable modal region by selector fully with scroll stitching': {skipEmit: true},
    'check scrollable modal region by selector fully with vg': {skipEmit: true},
    'check regions by coordinates in overflowed frame with vg': {skipEmit: true},
    'check window fully with html scrollRootElement after scroll with css stitching': {skipEmit: true},
    'check window fully with html scrollRootElement after scroll with scroll stitching': {skipEmit: true},
    // Not implemented layout breakpoints
    'check window with layout breakpoints': {skipEmit: true},
    'check window with layout breakpoints in config': {skipEmit: true},
    // Set_viewport_size method should work without Eyes instance
    'should set viewport size on edge legacy': {skip: true},
    // Hover errors
    'check hovered region by element with css stitching': {skip: true}, // Error: Applitools::OutOfBoundsException: Region (0, 0), 0 x 0 is out of screenshot bounds.
    'check hovered region by element with scroll stitching': {skip: true}, // Diff, hovered element was checked without hovering
    // Chrome emulator have wrong type of browser used
    'check window fully on android chrome emulator on desktop page': {skip: true},  //diffs

    // Diffs
    'acme login with css stitching': {skip: true},
    'acme login with scroll stitching': {skip: true},
    'check region by coordinates in frame fully with css stitching': {skip: true},
    'check region by coordinates in frame fully with scroll stitching': {skip: true},
    'check region by coordinates in frame with scroll stitching': {skip: true},
    'check region by coordinates in frame with css stitching': {skip: true},
    'check region by selector after manual scroll with css stitching': {skip: true},
    'check region by selector in overflowed frame after manual scroll with css stitching': {skip: true},
    'check region by selector after manual scroll with scroll stitching': {config: {branchName: 'current_ruby'}}, // diffs if compare to common baseline
    'check region by selector fully on page with sticky header with css stitching': {skip: true},
    'check region by selector fully on page with sticky header with scroll stitching': {skip: true},
    'check region by selector in frame multiple times with scroll stitching': {config: {parentBranchName: 'current_ruby', branchName: 'current_ruby'}},
    'check region by selector in frame multiple times with css stitching': {config: {parentBranchName: 'current_ruby', branchName: 'current_ruby'}},
    'check region by selector on page with sticky header with css stitching': {skip: true},
    'check region by selector on page with sticky header with scroll stitching': {skip: true},
    'check region fully after scroll non scrollable element with css stitching': {skip: true},
    'check region with fractional metrics by selector': {skip: true},
    'check region in frame hidden under top bar fully with scroll stitching': {config: {branchName: 'current_ruby'}},
    'check window after manual scroll with vg': {skip: true},
    'check window after manual scroll with scroll stitching': {skip: true},
    'check window fully on page with sticky header with scroll stitching': {skip: true},
    'check frame with css stitching': {skip: true},
    'check frame with scroll stitching': {skip: true},
    'check overflowed region by coordinates with scroll stitching': {skip: true},
    'check overflowed region by coordinates with css stitching': {skip: true},
    'check window fully on page with burger menu': {skip: true},
    'check window on page with sticky header with vg': {skip: true},
    'check fixed region by selector fully with css stitching': {skip: true},
    'check fixed region by selector with css stitching': {skip: true},
    'check frame fully with vg': {skip: true},
    'check frame fully with css stitching': {config: {branchName: 'current_ruby'}}, // diffs if compare to common baseline
    'check frame after manual switch to frame with scroll stitching classic': {config: {parentBranchName: 'current_ruby', branchName: 'current_ruby'}},
    'should send floating region by coordinates in frame with css stitching': {config: {parentBranchName: 'current_ruby', branchName: 'current_ruby'}},
    'should send floating region by coordinates in frame with vg': {skip: true},
    'should send ignore region by coordinates with css stitching': {skip: true},

    // Assertion error
    'should send accessibility regions by selector with css stitching': {skip: true},
    'should send floating region by coordinates with vg': {skip: true},
    'should send floating region by coordinates with scroll stitching': {skip: true},
    'should send floating region by coordinates in frame with scroll stitching': {skip: true},
    'should send ignore region by selector with vg': {skip: true},
    'should send ignore regions by selector with vg': {skip: true},
    'should send ignore regions by selector with scroll stitching': {skip: true},
    'should send ignore regions by selector with css stitching': {skip: true},
    'should send ignore region by the same selector as target region with vg': {skip: true},
    'should send accessibility regions by selector with scroll stitching': {skip: true},
    'should send ignore region by coordinates in target region with vg': {skip: true},
    'should send ignore region by coordinates in target region with scroll stitching': {skip: true},
    'should send ignore region by coordinates in target region with css stitching': {skip: true},
    'should send region by selector in padded page': {skip: true},
    'should send floating region by selector with css stitching': {skip: true},
    'should send floating region by selector with scroll stitching': {skip: true},
    'should send floating region by coordinates with css stitching': {skip: true},
    'should send floating region by selector with vg': {skip: true},
    'should send dom on ie': {skip: true},


    // Applitools::OutOfBoundsException => Region (0, 0), 0 x 0 is out of screenshot bounds.
    'check region by selector in overflowed frame after manual scroll with scroll stitching': {skip: true},
    'check region by selector in overflowed frame with scroll stitching': {skip: true},
    'check frame after manual switch to frame with css stitching classic': {skip: true},


    // Applitools::EyesError => Can't parse CSS transition: translate(0px)!
    'check window fully on page with horizontal scroll with css stitching': {skip: true},

    //Failure/Error: @driver = @eyes.open(driver: @driver)
    //
    //      Applitools::TestFailedError:
    //        Selenium::WebDriver::Error::InvalidArgumentError - The specified arguments passed to the command are invalid.
    'should send dom on edge legacy': {skip: true},

    // Couldn't pass the locator to the Applitools::Selenium::Target.frame receive correctly only the element
    'check frame in frame fully with css stitching': {skip: true},
    'check frame in frame fully with scroll stitching': {skip: true},
    'check frame in frame fully with vg': {skip: true},
    'check window fully and frame in frame fully with scroll stitching': {skip: true},
    'check window fully and frame in frame fully with css stitching': {skip: true},
    'check window fully and frame in frame fully with vg': {skip: true},

    // Applitools::TestFailedError => Selenium::WebDriver::Error::NoSuchWindowError
    'check window after manual scroll on safari 12': {skip: true},
    'check window after manual scroll on safari 11': {skip: true},

    // Undefined method 'state' for nil:NilClass
    'should not check if disabled': {skip: true},

    // A bug in the full page algorithm to fix
    'check window fully with html scrollRootElement after scroll when fail to scroll with scroll stitching': {skipEmit: true},
    'check window fully with html scrollRootElement after scroll when fail to scroll with css stitching': {skipEmit: true},
    'should not fail if scroll root is stale on android': {skipEmit: true},
    'check region by selector in frame fully on firefox legacy': { skipEmit: true },
    'adopted styleSheets on chrome': {skipEmit: true},
	'adopted styleSheets on firefox': {skipEmit: true},
    'variant id with vg': {skip: true},
    // Scroll root option not implemented in the ruby SDK
    'should send dom and location when check region by selector fully with custom scroll root with vg': {skipEmit: true},
}
