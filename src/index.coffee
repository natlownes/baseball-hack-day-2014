crypto = require 'crypto'

fs         = require 'fs'
Q          = require 'q'
$          = require 'jquery'
Backbone   = require 'backbone'
_ = Backbone._
Backbone.$ = $

apiRoot = 'https://s3.amazonaws.com/api.baseball.narf.io/v1/seasons/'
seenPlayers = {}


class SelectView extends Backbone.View


class TeamSelect extends SelectView

  constructor: (@teams) ->
    super

  events:
    'change select': 'teamSelected'

  template: ->
    options = for id, data of @teams
      """<option value="#{id}">#{data.name}</options>"""

    """
    <select name="team">
    #{options.join('')}
    </select>
    """

  selectedTeamId: ->
    @$('select option:selected').val()

  teamSelected: =>
    team = @teams[@selectedTeamId()]
    @trigger 'selected', team

  render: ->
    @$el.html(@template())
    this


class YearSelect extends SelectView

  events: ->
    'change select': 'yearSelected'

  template: (team) ->
    yearOptions = for year in team.years_active
      """<option value="#{year}">#{year}</options>"""

    """
    <select name="year">
    #{yearOptions.join('')}
    </select>
    """

  selectedYear: ->
    @$('option:selected').val()

  yearSelected: =>
    @trigger 'selected', @team, @selectedYear()

  list: (@team) ->
    @render(@team)

  render: (team) ->
    if team
      @$el.empty()
      @$el.append(@template(team))
    this


class Player extends Backbone.View
  tagName: 'div'
  # cssClass major mid minor

  player: ->
    @_player or= seenPlayers[@playerId]

  constructor: (opts) ->
    @stats         = opts.stats
    @playerId      = opts.playerId
    @name          = @player().name
    @positionNames = @stats.positions
    @startsCount   = @stats.startsCount
    @totalGames    = @stats.total_games
    @percentage    = @startsCount / @totalGames
    super(opts)

  template: ->
    """
      <span class="number">23</span>
      <span class="position">#{@positionNames.join(',')}</span>

      <div class="info">
        <span class="name">#{@name}</span>
        <span class="games-started">#{@startsCount}</span>
      </div>
    """

  render: ->
    @$el.html(@template())
    @$el.width("#{@percentage}")
    this


class BattingOrder extends Backbone.View
  tagName: 'tr'

  constructor: (opts) ->
    @slotNumber = opts.slotNumber
    @playerDict = opts.playerDict
    @container = opts.container
    @battingOrderPosition = @slotNumber
    super(opts)

  template: ->
    """
    <td>#{@battingOrderPosition}</td>
    <td class="players"></td>
    """

  render: ->
    for playerId, stats of @playerDict
      view = new Player(playerId: playerId, stats: stats)
      @container.$('.lineup-positions').append(view.render().el)
    this


class Lineups extends Backbone.View

  show: (@team, @year) ->
    @render()

  url: ->
    "#{apiRoot}#{@year}/#{@team.id}"

  map: ->
    starts = {}
    $.getJSON(@url()).then (season) ->
      for game in season.games
        for player, index in game.starting_lineup
          battingOrderPosition = index + 1
          starts[battingOrderPosition] or= {}
          starts[battingOrderPosition][player.id] or= {}
          starts[battingOrderPosition][player.id]['positions'] or= []
          starts[battingOrderPosition][player.id]['total_games'] = season.games.length

          positions = starts[battingOrderPosition][player.id]['positions']
          if positions.indexOf(player.position.name) is -1
            starts[battingOrderPosition][player.id]['positions']
              .push(player.position.name)
          startsCount = starts[battingOrderPosition][player.id]['startsCount'] or 0
          starts[battingOrderPosition][player.id]['startsCount'] = ++startsCount

          seenPlayers[player.id] or= player

      #for battingOrderPosition in starts
        #_.sortBy starts, (p) -> p.startsCount
      starts

  render: ->
    if @team and @year
      @map().then (starts) =>
        for slotNumber, playerDict of starts
          do (slotNumber, playerDict) =>
            @_addSlot(slotNumber, playerDict)
      @$el.html(@template())
    this

  _addSlot: (slotNumber, playerDict) =>
    orderView = new BattingOrder
      slotNumber: slotNumber
      playerDict: playerDict
      container: this
    orderView.render()

  template: ->
    """
      <tr>
        <th></th>
        <th>#{@year}</th>
      </tr>

      <span class="lineup-positions">
      </span>
    """


class App
  views: {}

  constructor: (teams) ->
    @views['teams'] = new TeamSelect(teams)
    @views['years'] = new YearSelect
    @views['lineups'] =  new Lineups(el: $('table'))

    @views.teams.on 'selected', (team) =>
      @views.years.list(team)

    @views.years.on 'selected', (team, year) =>
      @views.lineups.show(team, year)

  render: ->
    for name, view of @views
      $(".#{name}").append(view.render().el)
    this


$.getJSON('http://localhost:8222/teams.json').done (teams) ->
  app = new App(teams)
  app.render()

module.exports = {
  YearSelect
  App
}
