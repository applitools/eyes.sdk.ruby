'use strict';

const RUBY_CAPABILITIES = {
    browserName: 'browser_name',
    browserVersion: 'browser_version',
    platformName: 'platform_name'
};

const SELECTOR_TYPES = {
    css: 'css',
    className: 'class',
    UIAutomator: 'uiautomator',
    id: 'id',
    xpath: 'xpath',
    accessibilityId: 'accessibility_id',
    iOSPredicate: 'predicate'
}

function checkSettings(cs, isMobile = false) {
    let ruby = `Applitools::${isMobile? 'Appium' : 'Selenium'}::Target`;
    if (cs === undefined) {
        return ruby + '.window'
    }
    let element = '';
    let options = '';
    if (cs.frames === undefined && cs.region === undefined) element = '.window';
    else {
        if (cs.frames) element += frames(cs.frames);
        if (cs.region) element += region(cs.region)
    }
    if (cs.ignoreRegions) options += ignoreRegions(cs.ignoreRegions);
    if (cs.isFully) options += '.fully';
    return ruby + element + options

    function frames(arr) {
        return arr.reduce((acc, val) => acc + `.frame(css: \'${val}\')`, '')
    }

    function region(region) {
        return `.region(${regionParameter(region)})`
    }

    function ignoreRegions(arr) {
        return arr.reduce((acc, val) => acc + ignore(val), '')
    }

    function ignore(region) {
        return `.ignore(${regionParameter(region)})`
    }

    function regionParameter(region) {
        let string;
        if (isMobile) {
            string = `my_find(@driver, '${region}')`//`@driver.find_element(:${SELECTOR_TYPES[region.type]}, \'${region.selector}\')`
        } else if (typeof region === "object") {
            string = `Applitools::Region.new(${region.left}, ${region.top}, ${region.width}, ${region.height})`
        } else {
            string = `css: \'${region}\'`;
        }
        return string
    }
}


function ruby(chunks, ...values) {
    let code = '';
    values.forEach((value, index) => {
        let stringified = '';
        if (value && value.isRef) {
            stringified = value.ref()
        } else if (value && value.isHash) {
            stringified = JSON.stringify(value.hash)
                .replace(/":"/g, '" => "')
                .replace(/,/g, ', ')
                .replace(/"/g, `'`)
        } else if (typeof value === 'function') {
            stringified = value.toString()
        } else if (typeof value === 'undefined' || value === null) {
            stringified = 'nil'
        } else {
            stringified = JSON.stringify(value)
        }
        code += chunks[index] + stringified
    });
    return code + chunks[chunks.length - 1]
}

function driverBuild(caps, host) {
    let indent = spaces => ' '.repeat(spaces);
    let nl = `
    `;
    let string = `@driver = Selenium::WebDriver.for :remote`;
    if (!caps && !host) string += `, desired_capabilities: :chrome`;
    if (caps) string += capsToRuby(caps);
    if (host) string += `,${nl}${indent(34)}url: '${host}'`;
    return string;

    function capsToRuby(capabilities) {
        let cap = (key, value) => `${key}: '${value}',`
        let string = (key, value) => RUBY_CAPABILITIES[key] !== undefined ? cap(RUBY_CAPABILITIES[key], value) : cap(key, value);
        let transformCaps = (obj, indentation) => Object.keys(obj)
            .map(property => typeof obj[property] === 'string'
                ? string(property, obj[property])
                : `'${property}' => ${transformCaps(obj[property], indentation + 2)}`)
            .reverse()
            .concat('{')
            .reverse()
            .join(`${nl}${indent(indentation)}`)
            .concat(`${nl}${indent(indentation - 2)}}`)
        let rubyCapabilities = transformCaps(capabilities, 36)
        let rubyCaps = `,${nl}${indent(34)}desired_capabilities: ${rubyCapabilities}`;
        return rubyCaps
    }
}

module.exports = {
    checkSettingsParser: checkSettings,
    ruby: ruby,
    driverBuild: driverBuild,
    SELECTOR_TYPES: SELECTOR_TYPES
};
