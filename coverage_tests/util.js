'use strict'

function has(object, keys) {
    if (object == null) {
        return false
    }

    if (!Array.isArray(keys)) {
        keys = [keys]
    }

    for (const key of keys) {
        if (!hasOwnProperty.call(object, key)) {
            return false
        }
    }

    return true
}

function isSelector(selector) {
    return has(selector, ['type', 'selector'])
}

function wrapSelector(val) {
    return val.selector ? val : {type: 'css', selector: val}
}

function pascalToSnakeCase(string) {
    if (!string) return string
    return string.replace(/\.?([A-Z]+)/g, (symbol) => {
        return `_${symbol.toLowerCase()}`
    })
}

module.exports = {
    isSelector: isSelector,
    has: has,
    wrapSelector: wrapSelector,
    pascalToSnakeCase: pascalToSnakeCase,
}