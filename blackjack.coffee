# Run this with "coffee blackjack.coffee"

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
  can_wager: (amount) -> @bank.at_least amount
  wager: (amount) ->
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

class Table
  seat: (@player) ->
  play_game: =>
    return unless @player.can_wager @minimum_wager
    this.begin_game()
    this.collect_bets()
    this.deal()
    this.reveal()
    this.handle_money()
    this.end_game()
  games: 0
  minimum_wager: new Money(11)
  begin_game: ->
    @games += 1
    console.log "** begin game #{@games} **"
    console.log "Players:\n  - #{@player}"
  end_game: ->
    console.log "** end game #{@games} **\n"
  collect_bets: ->
    @wager = @player.wager @minimum_wager
  deal: ->
    console.log "The cards are dealt"
    @score = new Score(17)
    @player.score = new Score(14)
  reveal: ->
    @player.reveal()
    console.log "Dealer has #{@score}"
  handle_money: ->
    if @score.greaterThan @player.score
      console.log "Dealer wins"
      @player.lose @wager
    else
      console.log "#{@player.name} wins!"
      @player.win @wager.minus(new Money(1))



console.log "** Welcome to Blackjack **\n"
player = new Player("Pat")
table = new Table
table.seat player
500.times table.play_game

console.log "#{player.name} leaves after #{table.games} games, with #{player.bank} in his pocket"