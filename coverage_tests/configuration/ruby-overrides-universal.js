module.exports = {
    // no such element: Unable to locate element
    // fail on find-element-in-frame without switching


    //Applitools::EyesError:
    //        Request failed: Locator Strategy 'css selector' is not supported for this session
    'appium android check region with ignore region': {skip: true},

    //New test error
    'check region by selector in frame fully on firefox legacy': {skip:true},

    //Applitools::EyesError:
    //        Request failed: invalid selector: An invalid or illegal selector was specified
    'should send region by selector in padded page': {skip:true},

    // Shadow dom JS errors
    'check region by element within shadow dom with vg': {skip: true},
    'check region by selector within shadow dom with vg': {skip: true},

    // Applitools::DiffsFoundError (vg & fully)
    'check frame after manual switch to frame with vg classic': {skip: true},
    'check window two times with vg classic': {skip: true},
    'check window with vg classic': {skip: true},
}
