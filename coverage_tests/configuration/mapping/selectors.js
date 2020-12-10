module.exports = {
    "css": (selector) => `:css, ${selector})`,
    "class name": (selector) => `:class_name, ${selector})`,
    "id": (selector) => `:id, ${selector})`,
    "xpath": (selector) => `:xpath, ${selector})`,
    "name": (selector) => `:name, ${selector})`,
    "accessibility id": (selector) => `:accessibility_id, ${selector})`,
    "-android uiautomator": (selector) => `:uiautomator, ${selector})`,
    "androidViewTag": (selector) => `:viewtag, ${selector})`,
    "-ios predicate string": (selector) => `:predicate, ${selector})`,
    "-ios class chain": (selector) => `:class_chain, ${selector})`,
}