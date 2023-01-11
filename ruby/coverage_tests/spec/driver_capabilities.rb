# frozen_string_literal: true

require 'selenium-webdriver'

SAUCE_SERVER_URL = 'https://ondemand.us-west-1.saucelabs.com/wd/hub'
SAUCE_CREDENTIALS = {
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
            w3c: {
                browser_name: '',
                platform_name: 'Android',
                'appium:deviceName': 'Android Emulator',
                'appium:platformVersion': '6.0',
            },
            legacy: {
                browserName: '',
                platformName: 'Android',
                deviceName: 'Android Emulator',
                platformVersion: '6.0',
            }
        },
        options: {
            clearSystemFiles: true,
            noReset: true
        }.merge(SAUCE_CREDENTIALS)
    },
    'Pixel 3a XL' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browser_name: '',
                platform_name: 'Android',
                'appium:platformVersion': '10.0',
                'appium:deviceName': 'Google Pixel 3a XL GoogleAPI Emulator',
            },
            legacy: {
                browserName: '',
                deviceName: 'Google Pixel 3a XL GoogleAPI Emulator',
                platformName: 'Android',
                platformVersion: '10.0',
            },
        },
        options: {
            appiumVersion: '1.20.2'
        }.merge(SAUCE_CREDENTIALS)
    },
    'Pixel 3 XL' => {
        capabilities: {
            w3c: {
                browser_name: '',
                platform_name: 'Android',
                'appium:platformVersion': '10.0',
                'appium:deviceName': 'Google Pixel 3 XL GoogleAPI Emulator',
            },
            legacy: {
                browserName: '',
                deviceName: 'Google Pixel 3 XL GoogleAPI Emulator',
                platformName: 'Android',
                platformVersion: '10.0',
            },
        },
        options: {}.merge(SAUCE_CREDENTIALS),
        url: SAUCE_SERVER_URL,
        sauce: true,
        type: 'sauce'
    },
    'Samsung Galaxy S8' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browser_name: '',
                platform_name: 'Android',
                'appium:platformVersion': '7.0',
                'appium:deviceName': 'Samsung Galaxy S8 FHD GoogleAPI Emulator',
                'appium:automationName': 'uiautomator2',
            },
            legacy: {
                browserName: '',
                platformName: 'Android',
                platformVersion: '7.0',
                deviceName: 'Samsung Galaxy S8 FHD GoogleAPI Emulator',
                automationName: 'uiautomator2',
            }
        },
        options: {
            commandTimeout: 600,
            name: 'Android Demo',
            appiumVersion: '1.9.1',
        }.merge(SAUCE_CREDENTIALS)
    },
    'iPhone 5S' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browser_name: '',
                platform_name: 'iOS',
                'appium:deviceName': 'iPhone 5s Simulator',
                'appium:platformVersion': '12.4',
            },
            legacy: {
                browserName: '',
                platformName: 'iOS',
                deviceName: 'iPhone 5s Simulator',
                platformVersion: '12.4',
            }
        },
        options: {}.merge(SAUCE_CREDENTIALS)
    },
    'iPhone 11 Pro' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browser_name: '',
                platform_name: 'iOS',
                'appium:deviceName': 'iPhone 11 Pro Simulator',
                'appium:platformVersion': '13.4',
            },
            legacy: {
                browserName: '',
                platformName: 'iOS',
                deviceName: 'iPhone 11 Pro Simulator',
                platformVersion: '13.4',
            }
        },
        options: {}.merge(SAUCE_CREDENTIALS)
    },
    'iPhone XS' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browser_name: '',
                platform_name: 'iOS',
                'appium:platformVersion': '13.0',
                'appium:deviceName': 'iPhone XS Simulator'
            },
            legacy: {
                browserName: '',
                platformName: 'iOS',
                platformVersion: '13.0',
                appiumVersion: '1.19.2',
                deviceName: 'iPhone XS Simulator'
            }
        },
        options: {}.merge(SAUCE_CREDENTIALS)
    },
    'iPad Air' => {
        type: 'sauce',
        url: SAUCE_SERVER_URL,
        capabilities: {
            w3c: {
                browserName: '',
                platformName: 'iOS',
                'appium:deviceName': 'iPad Air Simulator',
                'appium:platformVersion': '12.4',
            },
            legacy: {
                browserName: '',
                deviceName: 'iPad Air Simulator',
                platformVersion: '12.4',
                platformName: 'iOS'
            }
        },
        options: {}.merge(SAUCE_CREDENTIALS)
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
                platform: 'macOS 10.13',
                seleniumVersion: '3.4.0'
            }
        },
        options: {
            name: 'Safari 12',
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
