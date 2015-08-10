# ----- 
# -------> Music Maker :)
# ----- 

app     = require('express')()
http    = require('http').Server(app)
io      = require('socket.io')(http)

midi    = require 'midi'
Player  = require('./player')

# init midi

midiOut = new midi.output

try
  midiOut.openPort(0)
catch error
  midiOut.openVirtualPort 'test'

# init player

player     = new Player(midiOut,io)

#player.play()
# init sockets

io.on 'connection', (socket) ->
  console.log socket.conn.id + ' connected'

  socket.on 'cmd', (cmd) ->
    player[cmd] && player[cmd]()

  socket.on 'note', (note)->
    console.log note
    player.playNote note,127,1000

  socket.on 'disconnect', ->
    player.stop()
    console.log socket.conn.id + ' disconnected'

# init app

app.get '/', (req, res) ->
  res.sendFile  __dirname + '/www/index.html'

http.listen 3000, ->
  console.log 'listening on *:3000'

# Cool Exit :)

process.addListener "SIGTERM", ->
  player.stop()
  midiOut.closePort()




