#!/usr/bin/env node

const { promisify } = require('util')
const { readFile, watchFile } = require('fs')
const read = promisify(readFile)

const sendMessage = require('./protocol')(_ => {})
const setTheme = (bg, fg, opacity) => sendMessage({
    type: "setTheme",
    data: {
        darkSchemeBackgroundColor: bg + opacity,
        darkSchemeTextColor: fg + opacity
    },
    isNative: true
})

const opacity = "14"
const colorFile = process.env.HOME + '/.cache/wal/colors'
const onFileChange = async () => {
    const colors = (await read(colorFile)).toString().split("\n")
    setTheme(colors[0], colors[7], opacity)
}

watchFile(colorFile, onFileChange)
onFileChange()
