#!/usr/bin/env node

if (process.argv[2] === '-d') {
    require('./server.js')
} else {
    const { createConnection } = require('net')
    const SOCKET = '/tmp/i3-sidebar.sock'
    const sock = createConnection(SOCKET)
    sock.on('connect', () => {
        sock.write(JSON.stringify({
            name: process.argv[2],
            position: process.argv[3],
            ratio: process.argv[4],
            cmd: process.argv[5]
        }))
        sock.destroy()
    })
}