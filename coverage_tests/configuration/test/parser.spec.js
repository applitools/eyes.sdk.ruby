'use strict'
const assert = require('assert')
const {checkSettingsParser} = require('../parser')

describe('Check settings parser tests', () => {

    it('Window', () => {
        assert.deepStrictEqual(checkSettingsParser(undefined), `Applitools::Selenium::Target.window`)
    })

    it('Window fully', () => {
        assert.deepStrictEqual(checkSettingsParser({isFully:true}), `Applitools::Selenium::Target.window.fully`)
    })

    it('Region element', () => {
        assert.deepStrictEqual(checkSettingsParser({region:'#name'}), `Applitools::Selenium::Target.region(css: '#name')`)
    })

    it('Region rectangle', () => {
        assert.deepStrictEqual(checkSettingsParser({region: {left: 10, top: 20, width: 30, height: 40}}), `Applitools::Selenium::Target.region(Applitools::Region.new(10, 20, 30, 40)`)
    })

    it('Frames 1', () => {
        assert.deepStrictEqual(checkSettingsParser({frames: ['[name="frame1"]']}), `Applitools::Selenium::Target.frame(css: '[name="frame1"]')`)
    })

    it('Frames 2', () => {
        assert.deepStrictEqual(checkSettingsParser({frames: ['[name="frame1"]', '[name="frame2"]']}), `Applitools::Selenium::Target.frame(css: '[name="frame1"]').frame(css: '[name="frame2"]')`)
    })

    it('Region in frame', () => {
        assert.deepStrictEqual(checkSettingsParser({frames: ['[name="frame1"]'], region: '#name'}), `Applitools::Selenium::Target.frame(css: '[name="frame1"]').region(css: '#name')`)
    })

    it('Ignore region', () => {
        assert.deepStrictEqual(checkSettingsParser({ignoreRegions: ['#name']}), `Applitools::Selenium::Target.window.ignore(css: '#name')`)
    })


})