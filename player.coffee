t = require 'teoria'

class Player
  tmp : 0
  currBar : 0
  lp:null
  chords:[
    {
      'note':'c'
      'mode':'major'
      'sclae':'major'
    },
    {
      'note':'a'
      'mode':'minor'
      'sclae':'minor'
    },
    {
      'note':'d'
      'mode':'minor'
      'sclae':'minor'
    },
    {
      'note':'g'
      'mode':'7'
      'sclae':'majorpentatonic'
    }
  ]

  constructor: (@midi,@io) ->
    @playing     = false
    @bpm         = 50
    @currentStep = 1
    @totalSteps  = 16 # time signature

  playChord:(note,mode)->
    #console.log(note,mode,t.note(note).chord(mode))
    n = t.note(note)
    #@io.emit('note', n.name() + '/' + (n.octave()+ 1)  )
    @playNote(note,100,1000) for note in n.chord(mode).notes()
    
  barDuration: ->
    60000 / @bpm * 4
    
  stopNote: (note) ->
    @midi.sendMessage [128, note, 0]
    
  playNote: (note, velocity, duration) ->
    return unless note
    console.log note
    @midi.sendMessage [144, (if note.midi then note.midi() else note), velocity]
    setTimeout =>
      @stopNote note
    , duration

  barChange:()->
    console.log(@currBar,@chords[@currBar].note)
    @playChord(@chords[@currBar].note,@chords[@currBar].mode)

    if ++@currBar > 3
      @currBar = 0 
      @tmp = 0 
      
  play: ->
    return if @playing    
    @playing = true
    @lp = setInterval =>
        @barChange() if ++@tmp % 4 == 0 
        @playNote @getNote(), (Math.random() * 126).toFixed()
    , (this.barDuration() / @totalSteps)

  pause: ->
    clearInterval(@lp)
    @playing = false
 































  getNote: ->
    # n = t.note(@chords[@currBar].note).scale('majorpentatonic').notes()[(@tmp % 5)];
    # return n

    n = t.note(@chords[@currBar].note);

    if Math.random()>.3
      n = t.note("c").scale('major').notes()[(@tmp % 7)]
    if Math.random()>.8
      n = t.note("a").scale('minor').notes()[(@tmp % 7)]
      #n = t.note(@chords[@currBar].note).scale('major').notes()[(@tmp % 7)]
      #n = t.note(@chords[@currBar].note).scale().notes()[(@tmp % 7)]
    @io.emit('note', n.name() + '/' + (n.octave()+ 1)  )
    
    return n












  stop: ->
    @pause()
    @currentStep = 1
    @currBar = 0 
    @tmp = 0 
    @midi.sendMessage [252, 0, 0]
    @midi.sendMessage [176, 123, 0]

module.exports = Player