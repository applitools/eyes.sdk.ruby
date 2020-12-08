'use strict';
const types = require('./mapping/types')

const RUBY_CAPABILITIES = {
    browserName: 'browser_name',
    browserVersion: 'browser_version',
    platformName: 'platform_name'
};


function checkSettings(cs) {
    let ruby = `Applitools::Selenium::Target`;
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
}

function frames(arr) {
    return arr.reduce((acc, val) => acc + `${frame(val)}`, '')
}

function frame(val) {
    return val.isRef ? val.ref() : `.frame(css: \'${val}\')`
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
    switch (typeof region) {
        case 'string':
            string = `css: \'${region}\'`;
            break;
        case "object":
            string = `Applitools::Region.new(${region.left}, ${region.top}, ${region.width}, ${region.height})`
            break;
        default:
            string = serialize(region)
    }
    return string
}

function construct(chunks, ...values) {
    const commands = []

    function isPresent(values) {
        const value = (values.length > 0 && typeof values[0] !== 'undefined')
        return value && values[0].isRef ? values[0].ref() !== 'undefined' : value
    }

    const builder = {
        add(chunks, ...values) {
            commands.push(...ruby(chunks, ...values))
            return this
        },
        extra(chunks, ...values) {
            if (isPresent(values)) commands.push(...ruby(chunks, ...values))
            return this
        },
        build(separator = '') {
            return [commands.join(separator)]
        }
    }
    return builder.add(chunks, ...values)
}

function ruby(chunks, ...values) {
    const commands = []
    let code = ''
    values.forEach((value, index) => {
        if (typeof value === 'function' && !value.isRef) {
            code += chunks[index]
            commands.push(code, value)
            code = ''
        } else {
            code += chunks[index] + serialize(value)
        }
    })
    code += chunks[chunks.length - 1]
    commands.push(code)
    return commands
}

function serialize(value) {
    let stringified = '';
    if (value && value.isRef) {
        stringified = value.ref()
    } else if (typeof value === 'function') {
        stringified = value.toString()
    } else if (typeof value === 'undefined' || value === null) {
        stringified = 'nil'
    } else if (typeof value === 'string') {
        stringified = `'${value}'`
    } else if (typeof value === 'object') {
        stringified = `{${Object.keys(value).map(key => `"${key}" => ${value[key]}`).join(', ')}}`
     } else {
        stringified = JSON.stringify(value)
    }
    return stringified
}

function driverBuild(caps, host) {
    let indent = spaces => ' '.repeat(spaces);
    let nl = `
    `;
    let string = `@driver = Selenium::WebDriver.for :remote`;
    if (!caps && !host) string += `, desired_capabilities: {'browserName' => 'chrome', 'goog:chromeOptions' => {'args' => %w[--disable-gpu --headless]}}`;
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

function ref(val) {
    const wrapped = {
        isRef: true,
        ref: () => val,
        type: (type) => {
            if (type) {
                wrapped._type = type;
                const val = wrapped.ref();
                wrapped.ref = () => val ? types[type].constructor(val) : val
                return wrapped
            } else return wrapped._type;
        },
    }
    return wrapped
}

function variable({name, value}) {
    return `${name} = ${value}`
}

function getter({target, key, type}) {
    let get;
    if (type && type.name === 'Array') {
        get = `[${key}]`
    } else {
        get = key.startsWith('get') ? `.${key.slice(3).toLowerCase()}` : `[${serialize(key)}]`
    }
    return `${target}${get}`
}

function call({target, args}) {
    return args.length > 0 ? `${target}(${args.map(val => JSON.stringify(val)).join(", ")})` : `${target}`
}

function returnSyntax({value}) {
    return `return ${value}`
}


module.exports = {
    checkSettingsParser: checkSettings,
    ruby: ruby,
    driverBuild: driverBuild,
    construct: construct,
    ref: ref,
    variable: variable,
    getter: getter,
    call: call,
    returnSyntax: returnSyntax,
};