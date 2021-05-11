'use strict';
const types = require('./mapping/types')
const selectors = require('./mapping/selectors')
const {isSelector, pascalToSnakeCase} = require('./util')

function checkSettings(cs, driver, native) {
    let ruby =  native ? `target: Applitools::Appium::Target` : `Applitools::Selenium::Target`;
    if (cs === undefined) {
        return ruby + '.window'
    }
    let name = '';
    let element = '';
    let options = '';
    if (cs.frames === undefined && cs.region === undefined) element = '.window';
    else {
        if (cs.frames) element += frames(cs.frames);
        if (cs.region) element += region(cs.region)
    }
    if (cs.accessibilityRegions) options += accessibilityRegions(cs.accessibilityRegions)
    if (cs.layoutRegions) options += layoutRegions(cs.layoutRegions)
    if (cs.ignoreRegions) options += ignoreRegions(cs.ignoreRegions);
    if (cs.floatingRegions) options += floatingRegions(cs.floatingRegions);
    if (cs.scrollRootElement ) throw new Error("Scroll root option not implemented in the ruby SDK")
    if (cs.ignoreDisplacements !== undefined) options += `.ignore_displacements(${cs.ignoreDisplacements})`
    if (cs.sendDom !== undefined) options += `.send_dom(${serialize(cs.sendDom)})`
    if (cs.variationGroupId) options += `.variation_group_id(${serialize(cs.variationGroupId)})`
    if (cs.isFully) options += '.fully';
    if (cs.name) name = `'${cs.name}', `;
    return name + ruby + element + options

    function frames(arr) {
        return arr.reduce((acc, val) => acc + `${frame(val)}`, '')
    }

    function frame(val) {
        return ( !val.isRef && val.frame) ? `.frame(${frameSelector(val.frame)})` : `.frame(${frameSelector(val)})`
        function frameSelector(selector) {
            if(typeof selector === 'string' && !checkCss(selector)) {
                return JSON.stringify(selector)
            } else {
                return printSelector(selector);
            }
            function checkCss(string) {
                return (string.includes('[') && string.includes(']')) || string.includes('#')
            }
        }
        function printSelector(val) {
            return serialize((val && val.isRef) ? val : ref(`@driver.find_element(css: '${val}')`))
        }
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

    function floatingRegions(arr) {
        return arr.reduce((acc, val) => acc + floating(val), '')
    }

    function floating(floating) {
        return `.floating(${regionParameter(floating.region)}, ${floatingBounds(floating)})`
    }

    function floatingBounds(bounds) {
        return types.FloatingBounds.constructor(bounds)
    }

    function regionParameter(region) {
        let string;
        switch (typeof region) {
            case 'string':
                string = `:css, \'${region}\'`;
                break;
            case "object":
                string = region.selector ? serialize(region) : types.Region.constructor(region)
                break;
            default:
                string = serialize(region)
        }
        return string
    }

    function accessibilityRegions(regions) {

        return regions.map(accessibilityRegion).join('')

        function accessibilityRegion(reg) {
            return `.accessibility(${regionParameter(reg.region)}, type: ${serialize(reg.type)})`
        }
    }

    function layoutRegions(regions) {
        return regions.map(region => `.layout(${regionParameter(region)})`)
    }
}

function construct(chunks, ...values) {
    const commands = []
    function isPresent(values) {
        const value = (values.length > 0 && typeof values[0] !== 'undefined')
        return value && values[0].isRef ?
            values[0].ref() !== 'undefined' &&
            values[0].ref() !== undefined:
            value
    }

    const builder = {
        add(chunks, ...values) {
            commands.push(...ruby(chunks, ...values))
            return builder
        },
        notAdd() {
            return builder
        },
        extra(chunks, ...values) {
            if (isPresent(values)) commands.push(...ruby(chunks, ...values))
            return builder
        },
        build(separator = '') {
            return [commands.join(separator)]
        },
        addIf(bool) {
            return bool ? builder.add : builder.notAdd
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
    } else if (Array.isArray(value)) {
        stringified = `[${value.map(serialize).join(', ')}]`
    } else if (typeof value === 'function') {
        stringified = value.toString()
    } else if (typeof value === 'undefined' || value === null) {
        stringified = 'nil'
    } else if (typeof value === 'string') {
        stringified = `'${value}'`
    } else if (isSelector(value)) {
        stringified = selectors[value.type](value.selector)
    } else if (typeof value === 'object') {
        stringified = `{ ${Object.keys(value).map(key => `${serialize(key)} => ${serialize(value[key])}`).join(', ')} }`
    } else {
        stringified = JSON.stringify(value)
    }
    return stringified
}

function driverBuild(env) {
    let parsed = env ? '(' +
        Object.keys(env).map(key => `${key}: '${env[key]}'`).join(', ') +
        ')' : ''
    let string = `@driver = build_driver${parsed}`
    return string
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
        get = key === 'length' ? `.${key}` : `[${key}]`
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

function getClassName(coverageClassName) {
    if (!types[coverageClassName]) throw new Error(`There is no type for the ${coverageClassName}`)
    return ref(types[coverageClassName].class())
}

function prepareTestConfig(config) {
    return Object.keys(config).map(property => `${pascalToSnakeCase(property)}: ${serialize(config[property])}`).join(', ')
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
    getClassName: getClassName,
    prepareTestConfig: prepareTestConfig,
};