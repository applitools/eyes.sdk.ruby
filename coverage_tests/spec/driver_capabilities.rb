# frozen_string_literal: true

SAUCE_SERVER_URL = 'https://ondemand.saucelabs.com:443/wd/hub'
SAUCE_CREDENTIALS = {
  :'sauce:username' => ENV['SAUCE_USERNAME'],
  :'sauce:accessKey' => ENV['SAUCE_ACCESS_KEY'],
    username: ENV['SAUCE_USERNAME'],
    accessKey: ENV['SAUCE_ACCESS_KEY']
}.freeze
BROWSER_OPTIONS_NAME = {
    'chrome' => 'goog:chromeOptions',
    'firefox' => 'moz:firefoxOptions'
}.freeze
FIREFOX_SERVER_URL = 'http://localhost:4445/wd/hub'
CHROME_SERVER_URL = 'http://localhost:4444/wd/hub'


DEVICES = {
    'Android Emulator' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            browserName: '',
            deviceName: 'Android Emulator',
            platformName: 'Android',
            platformVersion: '6.0',
            clearSystemFiles: true,
            noReset: true
        }.merge(SAUCE_CREDENTIALS)
    },
    'Pixel 3a XL' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            browserName: '',
            deviceName: 'Google Pixel 3a XL GoogleAPI Emulator',
            platformName: 'Android',
            platformVersion: '10.0',
            deviceOrientation: 'portrait'
        }.merge(SAUCE_CREDENTIALS)
    },
    'Pixel 3 XL' => {
        capabilities: {
            browserName: '',
            deviceName: 'Google Pixel 3 XL GoogleAPI Emulator',
            platformName: 'Android',
            platformVersion: '10.0',
            deviceOrientation: 'portrait'
        }.merge(SAUCE_CREDENTIALS),
        url: SAUCE_SERVER_URL,
        sauce: true,
        type: 'sauce'
    },
    'Samsung Galaxy S8' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            browserName: '',
            name: 'Android Demo',
            platformName: 'Android',
            platformVersion: '7.0',
            appiumVersion: '1.9.1',
            deviceName: 'Samsung Galaxy S8 FHD GoogleAPI Emulator',
            automationName: 'uiautomator2',
            newCommandTimeout: 600
        }.merge(SAUCE_CREDENTIALS)
    },
    'iPhone 5S' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            browserName: '',
            deviceName: 'iPhone 5s Simulator',
            platformVersion: '12.4',
            platformName: 'iOS'
        }.merge(SAUCE_CREDENTIALS)
    },
    'iPhone 11 Pro' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            browserName: '',
            deviceName: 'iPhone 11 Pro Simulator',
            platformVersion: '13.4',
            platformName: 'iOS'
        }.merge(SAUCE_CREDENTIALS)
    },
    'iPhone XS' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            browserName: '',
            platformName: 'iOS',
            platformVersion: '13.0',
            deviceName: 'iPhone XS Simulator'
        }.merge(SAUCE_CREDENTIALS)
    },
    'iPad Air' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            browserName: '',
            deviceName: 'iPad Air Simulator',
            platformVersion: '12.4',
            platformName: 'iOS'
        }.merge(SAUCE_CREDENTIALS)
    },
    'Android 8.0 Chrome Emulator' => {
        type: 'chrome',
        url: CHROME_SERVER_URL,
        capabilities: {
            browserName: 'chrome',
            BROWSER_OPTIONS_NAME['chrome'] => {
                mobileEmulation: {
                    deviceMetrics: {width: 384, height: 512, pixelRatio: 2},
                    userAgent:
                        'Mozilla/5.0 (Linux; Android 8.0.0; Android SDK built for x86_64 Build/OSR1.180418.004) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Mobile Safari/537.36'
                },
                args: ['hide-scrollbars']
            }
        }
    }
}.freeze

BROWSERS = {
    'edge-18' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            browserName: 'MicrosoftEdge',
            browserVersion: '18.17763',
            platformName: 'Windows 10'
        },
        options: {
            name: 'Edge 18',
            avoidProxy: true,
            screenResolution: '1920x1080'
        }.merge(SAUCE_CREDENTIALS)
    },
    'ie-11' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browserName: 'internet explorer',
                browserVersion: '11.285',
                platformName: 'Windows 10'
            },
            legacy: {
                browserName: 'internet explorer',
                platform: 'Windows 10',
                version: '11.285'
            }
        },
        options: {
            name: 'IE 11',
            screenResolution: '1920x1080'
        }.merge(SAUCE_CREDENTIALS)
    },
    'safari-11' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browserName: 'safari',
                browserVersion: '11.1',
                platformName: 'macOS 10.13'
            },
            legacy: {
                browserName: 'safari',
                version: '11.1',
                platform: 'macOS 10.13'
            }
        },
        options: {
            name: 'Safari 11',
            seleniumVersion: '3.4.0'
        }.merge(SAUCE_CREDENTIALS)
    },
    'safari-12' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browserName: 'safari',
                browserVersion: '12.1',
                platformName: 'macOS 10.13'
            },
            legacy: {
                browserName: 'safari',
                version: '12.1',
                platform: 'macOS 10.13'
            }
        },
        options: {
            name: 'Safari 12',
            seleniumVersion: '3.4.0'
        }.merge(SAUCE_CREDENTIALS)
    },
    'firefox-48' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            legacy: {
                browserName: 'firefox',
                platform: 'Windows 10',
                version: '48.0'
            }
        },
        options: {
            name: 'Firefox 48'
        }.merge(SAUCE_CREDENTIALS)
    },
    'firefox' => {
        type: 'firefox',
        url: FIREFOX_SERVER_URL,
        capabilities: {
            browserName: 'firefox',
            BROWSER_OPTIONS_NAME['firefox'] => {
                args: []
            }
        }
    },
    'chrome' => {
        type: 'chrome',
        capabilities: {
            browserName: 'chrome',
            BROWSER_OPTIONS_NAME['chrome'] => {
                args: []
            }
        }
    }
}.freeze
