# Run this with "coffee blackjack.coffee"
_ = require('underscore')

Array::remove = (e) -> this.splice(this.indexOf(e), 1)
Array::clone = ->
  cloned = []
  for i in this
    cloned.push i
  cloned

Number::times = (funktion) ->
  for x in [1..this]
    funktion.call x

class Money
  constructor: (@value) ->
  toString: -> "$#{@value}"
  minus: (other) ->
    new Money(@value - other.value)
  plus: (other) ->
    new Money(@value + other.value)
  atLeast: (other) -> @value >= other.value

class Score
  constructor: ->
    @score = Math.floor(Math.random() * 21) + 1
  greaterThan: (other) ->
    @score > other.score
  toString: -> @score

class Player
  constructor: (@name) ->
    @bank = new Money(100)
  toString: -> @name + " (" + @bank + ")"
  games: 0
  canWager: (amount) -> @bank.atLeast amount
  wager: (amount) ->
    @games += 1
    console.log "#{@name} wagers #{amount}"
    amount
  lose: (amount) ->
    console.log "#{@name} loses #{amount}"
    @bank = @bank.minus amount
  win: (amount) ->
    console.log "#{@name} wins #{amount}"
    @bank = @bank.plus amount
  reveal: ->
    console.log "#{@name} has #{@score}"
  leave: ->
    console.log "#{@name} leaves after #{@games} games, with #{@bank} in his pocket"

class Table
  seat: (player) ->
    if player.canWager @wagerAmount
      @players.push player
    else
      console.log "#{player.name} must have at least #{@wagerAmount} in the bank to play."
  unseat: (player) ->
    player.leave()
    @players.remove player
  playGame: =>
    if this.beginGame()
      this.collectBets()
      this.deal()
      this.reveal()
      this.handleMoney()
      this.endGame()
  wagerAmount: new Money(11)
  players: []
  games: 0
  beginGame: ->
    return false unless @players.length > 0
    @games += 1
    console.log "** begin game #{@games} **"
    console.log "Players:"
    this.eachPlayer((player) -> console.log " - #{player}")
    console.log ""
    true
  endGame: ->
    this.eachPlayer((player) -> this.unseat(player) unless player.canWager(@wagerAmount))
    console.log "** end game #{@games} **\n"
  closeTable: ->
    this.eachPlayer((player) -> this.unseat player)
    console.log "** Thanks for playing! **"
  collectBets: ->
    wagerAmount = @wagerAmount
    _.each(@players, (player) -> player.wager wagerAmount)
  deal: ->
    console.log "The cards are dealt"
    @score = new Score(21)
    this.eachPlayer((player) -> player.score = new Score(21))
  reveal: ->
    this.eachPlayer((player) -> player.reveal())
    console.log "Dealer has #{@score}"
  handleMoney: ->
    this.eachPlayer((player) ->
      if @score.greaterThan player.score
        console.log "Dealer beats #{player.name}"
        player.lose @wagerAmount
      else
        console.log "#{player.name} beats Dealer!"
        player.win @wagerAmount.minus(new Money(1))
      )
  eachPlayer: (funktion) ->
    _.each(@players.clone(), funktion, this)

console.log "** Welcome to Blackjack **\n"
table = new Table()
table.seat(new Player("Pat"))
table.seat(new Player("Jay"))
100.times table.playGame
table.closeTable()
