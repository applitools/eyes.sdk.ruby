const types = {
    "RectangleSize": {
        constructor: (value) => `Applitools::RectangleSize.new(${value.width}, ${value.height})`
    },
    "Region": {
        constructor: (region) => `Applitools::Region.new(${region.left}, ${region.top}, ${region.width}, ${region.height})`
    },
    "FloatingBounds": {
        constructor: (bounds) => `Applitools::FloatingBounds.new(${bounds.maxLeftOffset}, ${bounds.maxUpOffset}, ${bounds.maxRightOffset}, ${bounds.maxDownOffset})`
    },
    "TestResults": {
        class: () => `Applitools::TestResults`
    }
}

module.exports = types