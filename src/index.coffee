crypto = require 'crypto'

fs         = require 'fs'
Q          = require 'q'
$          = require 'jquery'
Backbone   = require 'backbone'
Backbone.$ = $

apiRoot = 'https://s3.amazonaws.com/api.baseball.narf.io/v1/seasons/'


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
  events:
    'change select': 'fetchSeason'

  template: (team) ->
    yearOptions = for year in team.years_active
      """<option value="#{year}">#{year}</options>"""
    """
    <select name="year">
       #{yearOptions.join('')}
    </select>
    """

  selectedYear: ->
    @$('select option:selected').val()

  fetchSeason: =>
    url = "#{apiRoot}#{@selectedYear()}/#{@team.id}"

  list: (@team) ->
    @render(@team)

  render: (team) ->
    console.log @team
    if team
      @$el.html @template(team)
    this


class App
  views: {}

  constructor: (teams) ->
    @views['teams'] = new TeamSelect(teams)
    @views['years'] = new YearSelect

    @views.teams.on 'selected', (team) =>
      @views.years.list(team)

  render: ->
    for name, view of @views
      $(".#{name}").append(view.render().el)
    this

team      = 'PHI'
startYear = 1992
endYear   = 1994

years = [startYear..endYear]

requests = for year in years
  $.getJSON("#{apiRoot}#{year}/#{team}")

$.getJSON('http://localhost:8222/teams.json').done (teams) ->
  app = new App(teams)
  app.render()


module.exports = {
  YearSelect
  App
}
