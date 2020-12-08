const types = {
    "RectangleSize": {
        constructor: (value) => `Applitools::RectangleSize.new(${value.width}, ${value.height})`
    }
}

module.exports = types