## [3.17.14] - 2020-07-9
### Updated
- Added missing `StitchingService` URI field in `RenderRequest`. [Trello 1988](https://trello.com/c/Yr6EsUlL)
## [3.17.13] - 2020-07-03
## Fixed
- eyes_appium: Coded Floating Regions Incorrectly Placed [Trello_1960](https://trello.com/c/j6nJh1LS/1960-ruby-native-app-coded-floating-regions-incorrectly-placed)
- eyes_images: Simple eyes_images test is broken [Trello_1949](https://trello.com/c/dHQbz96i/1949-eyesimages-seem-to-be-broken)
## [3.17.12] - 2020-07-02
## Fixed
- :match_timeout property is moved to configuration object [Trello_1935](https://trello.com/c/2Z070Qgs/1935-ruby-selenium-matchtimeout-not-available-in-the-configuration-object)
## [3.17.11] - 2020-06-25
## Fixed
- IosDeviceOrientation is replaced by Orientation [Trello_1944](https://trello.com/c/EzyG7525/1944-ufg-safari-on-ios-orientations-changes)
## [Eyes.sdk.ruby 3.17.10] - 2020-06-20
## Fixed
- a configuration shared between Eyes instances in Rspec [Trello_1938](https://trello.com/c/qOQkbDO7/1938-a-configuration-shared-between-eyes-instances-in-rspec)
## [Eyes.sdk.ruby 3.17.9] - 2020-06-19
## Fixed
- Call :clone on a NilClass for ruby 2.3 [Trello_1855](https://trello.com/c/LCBhnTMd/1885-selenium-ruby-cant-clone-nilclass)
## [Eyes.sdk.ruby 3.17.7] - 2020-06-18
## Added
- eyes.ignore_displacements= and eyes.ignore_displacements methods [Trello_841](https://trello.com/c/uwrYb1Vj/841-add-a-general-method-for-ignoredisplacements?menu=filter&filter=visual%20loca,due:notdue)
## Fixed
- Encoded regions for 'selector' mode [Trello_1915](https://trello.com/c/BQIrbCfC/1915-ruby-ultrafast-grid-incorrect-placement-of-coded-regions-for-targetregion)
## [Eyes.sdk.ruby 3.17.6] - 2020-06-16
## Fixed
- config.add_device_emulation(name, orientation) is fixed [Trello_1914](https://trello.com/c/l7WRvhSP/1914-ruby-ultrafast-grid-adddeviceemulation-throws-error-after-upgrading-to-3175?menu=filter&filter=due:notdue)
## Added
- Appium driver support is ectended (Applitools::Appium::Eyes.new(driver: Appium::Driver.new)) [Trello_1913](https://trello.com/c/wQTgRNrN/1913-appium-ruby-regression-unknown-driver-appiumdriver0x00007fbaf9903448-applitoolseyeserror?menu=filter&filter=due:notdue)
## [Eyes.sdk.ruby 3.17.5] - 2020-06-15
## Added
- The ability to set :baseline_env_name for DesktopBrowserInfo, IosDeviceInfo and ChromeEmulationInfo
## Fixed
- IosScreenOrientation instead of the IosScreenshotOrientation
## [Eyes.sdk.ruby 3.17.4] - 2020-06-11
## Fixed
- restricted to set emulation_info && ios_device_info for DesktopBrowserInfo
## [Eyes.sdk.ruby 3.17.3] - 2020-06-06
## Deprecated
- BrowserTypes module is deprecated in a favor of BrowserType
- Orientations module is deprecated in a favor of Orientation
## Fixed
- IosDeviceOrientation instead of IosDeviceOrientations(plural)
## Deprecated
## [Eyes.sdk.ruby 3.17.2] - 2020-06-06
## Added
- safari on ios device emulation for UFG [Trello_1872](https://trello.com/c/bykk2rzB/1872-ufg-safari-on-ios-simulators-support)
## [Eyes.sdk.ruby 3.17.1] - 2020-05-26
## Fixed
- eyes.properties for VG [Trello_1804](https://trello.com/c/Jt2BYz0e/1804-ruby-selenium-addproperty-method-not-recognized-when-running-with-visualgridrunner)
- SessionStartInfo parameters were not passed to Json correctly
## [Eyes.sdk.ruby 3.17.0] - 2020-05-18
## Added
- eyes.accessibility_validation(Applitools::AccessibilitySettings.new(Applitools::AccessibilityLevel::AA, Applitools::AccessibilityVersion::WCAG_2_0)) - [Trello_1767](https://trello.com/c/gq69woeK/1767-all-sdks-accessibility-accessiblity-guidelines-version-support-and-additional-verifications?menu=filter&filter=due:notdue)
## Removed
- eyes.accessibility_level
## [Eyes.sdk.ruby 3.16.16] - 2020-04-28
## Added
- Regions support for eyes_appium (Target#ignore, Target#floating, Target#accessibility, Target#layout, etc.)
## [Eyes.sdk.ruby 3.16.15] - 2020-04-24
## Deprecated
- BrowserTypes::EDGE is deprecated. Please change it to either "EDGE_LEGACY" for the legacy version or to "EDGE_CHROMIUM" for the new Chromium-based version. [Trello 1757](https://trello.com/c/LUe43aee/1757-all-ultrafast-sdks-edge-chromium-support)
## [Eyes.sdk.ruby 3.16.14] - 2020-04-10
## Added
-  new_session? flag is taken from start_session server response with fallback to the status code [Trello_1715](https://trello.com/c/DcVzWbeR/1715-all-sdks-updated-long-running-task-mode-for-startsession) 
## [Eyes.sdk.ruby 3.16.13] - 2020-04-06
## Fixed
- eyes#hide_scrollbars is true by default [Trello 1592](https://trello.com/c/MXixwLnj/1592-upload-dom-directly-to-azure)
- eyes#ignore_caret has been included tothe configuration object [Trello)_1706](https://trello.com/c/16JqYlYb/1706-ignorecaret-globally-is-missing-ruby)
- Irrelevant URLs are excluded from SVG resource parsing results [Trello 1691](https://trello.com/c/EAIpEh8s/1691-ruby-vg-parsing-of-irrelevant-urls-from-css-and-svg-resources)
## Added
-  x-applitools-eyes-client header for all API requests [Trello_1697](https://trello.com/c/CzhUxOqE/1697-all-sdks-should-report-their-version-in-all-requests-to-the-eyes-server) 
## [Eyes.sdk.ruby 3.16.12] - 2020-03-30
## Fixed
- eyes#send_dom didn't work [Trello 1659](https://trello.com/c/9CfD0fhn/1659-disable-dom-capturing-is-not-working-on-the-test-level-ruby)
## [Eyes.sdk.ruby 3.16.11] - 2020-03-27
## Fixed
- dom_capture threw an exception on a particular page [Trello 1658](https://trello.com/c/x0uYFwx0/1658-test-is-being-aborted-when-trying-to-capture-dom-ruby)
## [Eyes.sdk.ruby 3.16.10] - 2020-03-24
## Added
- The ability to use different Faraday adapters instead the default one [Trello 1683](https://trello.com/c/6IASHoBB/1683-add-http2-support-to-the-communication-library)
- The ability to set up timeout for HTTP request
- The ability to set up timeout for an Applitools::Future
## [Eyes.sdk.ruby 3.16.9] - 2020-03-17
## Fixed
- Agent ID for eyes_appium set to eyes.appium.ruby/version
## [Eyes.sdk.ruby 3.16.8] - 2020-03-13
## Fixed
- SDK fetch resources: the request header 'Accept-Language' is used along with 'User-Agent'
- Timeout for Thread.join is increased up to Faraday's connection timeout
- Error handling for resources that failed to fetch
## Added
-  Log messages for resource fetching now include the URL and status code
## [Eyes.sdk.ruby 3.16.7] - 2020-03-06
### Added
- dom_snapshot is uploaded directly to Azure storage
### Fixed
- dom_snapshot script updated to 7.1.3
- send_dom is true by default for EyesSelenium
## [Eyes.sdk.ruby 3.16.6] - 2020-03-05
### Fixed
- eyes#check might be called as #check(tag, target) as well as #check(target)
- Selenium Eyes: ignore regions in the current target caused an exception 
## [Eyes.sdk.ruby 3.16.5] - 2020-03-02
### Fixed
- double slash issue for custom server URL
## [Eyes.sdk.ruby 3.16.2] - 2020-02-06
### Fixed
- DefaultMatchSettings being overridden incorrectly by ImageMatchSettings
## [Eyes.sdk.ruby 3.16.1] - 2020-01-29
### Fixed
- eyes_appium crashed trying to get viewport_size
### Added
- long_requests are used for start session
## [Eyes.sdk.ruby 3.16.0] - 2020-01-24
### Added
- Screenshot uploading direct to cloud store
## [Eyes.sdk.ruby 3.15.48] - 2020-01-20
### Added
- New browser types for the VisualGrid (CHROME, CHROME_ONE_VERSION_BACK, CHROME_TWO_VERSIONS_BACK, FIREFOX, FIREFOX_ONE_VERSION_BACK, FIREFOX_TWO_VERSIONS_BACK, SAFARI, SAFARI_ONE_VERSION_BACK, SAFARI_TWO_VERSIONS_BACK, IE_10, IE_11, EDGE)
## [Eyes.sdk.ruby 3.15.47] - 2020-01-08
### Fixed
- eyes_images throws "undefined method `each' for nil:NilClass (NoMethodError)"
## [Eyes.sdk.ruby 3.15.43] - 2019-12-20
### Removed
- delta compression for screenshots
## [Eyes.sdk.ruby 3.15.43] - 2019-12-19
### Added
- eyes.abort_async method implementation
### Fixed
- save_new_tests is true by default
- tests are aborted instead of being closed on render fail
## [Eyes.sdk.ruby 3.15.43] - 2019-12-12
### Added
- Return empty test if the render fails
- eyes.abort method
## [Eyes.sdk.ruby 3.15.42] - 2019-12-10
### Fixed
- CSS paring & fetching font urls
- VisualGridEyes#config renamed to #configuration
- VisualGridEyes.configuration returns a clone of a configuration object
## [Eyes.sdk.ruby 3.15.41] - 2019-11-06
### Fixed
- Various VG related bugs
## [Eyes.sdk.ruby 3.15.39] - 2019-11-06
### Added
- This CHANGELOG file.
### Fixed
- Chrome 78 css stitching bug
