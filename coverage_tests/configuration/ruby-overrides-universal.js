module.exports = {
    // no such element: Unable to locate element
    // fail on find-element-in-frame without switching
    'check frame in frame fully with css stitching': {config: {branchName: 'v1'}, skip: true},
    'check frame in frame fully with scroll stitching': {config: {branchName: 'v1'}, skip: true},
    'check frame in frame fully with vg': {config: {branchName: 'v1'}, skip: true},
    'check window fully and frame in frame fully with css stitching': {config: {branchName: 'v2'}, skip: true},
    'check window fully and frame in frame fully with scroll stitching': {config: {branchName: 'v2'}, skip: true},
    'check window fully and frame in frame fully with vg': {config: {branchName: 'v2'}, skip: true},

    // Selenium::WebDriver::Error::NoSuchElementError:
    'check region by element within shadow dom with vg': {skip: true},

    // undefined method `quit' for Appium::Driver
    'check window fully on android chrome emulator on mobile page with horizontal scroll': {skip: true},
    'check window fully on android chrome emulator on mobile page': {skip: true},
    'should not fail if scroll root is stale on android': {skip: true},

    // expected: 350    got: 0
    'should send dom and location when check window with vg': {skip: true},

    // Applitools::NewTestError
    'check window after manual scroll on safari 11': {skip: true},

    // Applitools::DiffsFoundError
    'check frame after manual switch to frame with vg classic': {skip: true},
    'check region by selector in frame multiple times with css stitching': {skip: true},
    'check region by selector in frame multiple times with scroll stitching': {skip: true},
    'check region by selector within shadow dom with vg': {skip: true},
    'should send floating region by coordinates in frame with css stitching': {skip: true},
    'should send floating region by coordinates in frame with vg': {skip: true},
}
