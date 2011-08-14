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
  at_least: (other) -> @value >= other.value

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
  can_wager: (amount) -> @bank.at_least amount
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
    if player.can_wager @wager_amount
      @players.push player
    else
      console.log "#{player.name} must have at least #{@wager_amount} in the bank to play."
  unseat: (player) ->
    player.leave()
    @players.remove player
  play_game: =>
    if this.begin_game()
      this.collect_bets()
      this.deal()
      this.reveal()
      this.handle_money()
      this.end_game()
  wager_amount: new Money(11)
  players: []
  games: 0
  begin_game: ->
    return false unless @players.length > 0
    @games += 1
    console.log "** begin game #{@games} **"
    console.log "Players:"
    _.each(@players, (player) -> console.log " - #{player}")
    console.log ""
    true
  end_game: ->
    that = this
    wager_amount = @wager_amount
    _.each(@players.clone(), (player) -> that.unseat(player) unless player.can_wager(wager_amount))
    console.log "** end game #{@games} **\n"
  close_table: ->
    that = this
    _.each(@players.clone(), (player) -> that.unseat player)
    console.log "** Thanks for playing! **"
  collect_bets: ->
    wager_amount = @wager_amount
    _.each(@players, (player) -> player.wager wager_amount)
  deal: ->
    console.log "The cards are dealt"
    @score = new Score(21)
    _.each(@players, (player) -> player.score = new Score(21))
  reveal: ->
    _.each(@players, (player) -> player.reveal())
    console.log "Dealer has #{@score}"
  handle_money: ->
    score = @score
    wager_amount = @wager_amount
    _.each(@players, (player) ->
      if score.greaterThan player.score
        console.log "Dealer beats #{player.name}"
        player.lose wager_amount
      else
        console.log "#{player.name} beats Dealer!"
        player.win wager_amount.minus(new Money(1))
      )

console.log "** Welcome to Blackjack **\n"
table = new Table()
table.seat(new Player("Pat"))
table.seat(new Player("Jay"))
100.times table.play_game
table.close_table()
