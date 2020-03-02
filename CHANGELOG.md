## [Eyes.sdk.ruby 3.16.2] - 2020-03-02
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