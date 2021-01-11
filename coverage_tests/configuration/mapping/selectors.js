module.exports = {
    "css": (selector) => `:css, ${JSON.stringify(selector)}`,
    "class name": (selector) => `:class_name, ${JSON.stringify(selector)}`,
    "id": (selector) => `:id, ${JSON.stringify(selector)}`,
    "xpath": (selector) => `:xpath, ${JSON.stringify(selector)}`,
    "name": (selector) => `:name, ${JSON.stringify(selector)}`,
    "accessibility id": (selector) => `:accessibility_id, ${JSON.stringify(selector)}`,
    "-android uiautomator": (selector) => `:uiautomator, ${JSON.stringify(selector)}`,
    "androidViewTag": (selector) => `:viewtag, ${JSON.stringify(selector)}`,
    "-ios predicate string": (selector) => `:predicate, ${JSON.stringify(selector)}`,
    "-ios class chain": (selector) => `:class_chain, ${JSON.stringify(selector)}`,
}