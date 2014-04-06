crypto = require 'crypto'

Q        = require 'q'
$        = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $

#apiRoot   = 'http://localhost:8081/v1/seasons/'
apiRoot   = 'https://s3.amazonaws.com/api.baseball.narf.io/v1/seasons/'


class SelectView extends Backbone.View


class TeamSelect extends SelectView

  template: -> """
    <select name="team"></select>
  """


class YearSelect extends SelectView
  events:
    'change select': 'fetchTeamIndex'

  availableYearRange: [1920..2012]

  template: ->
    yearOptions = for year in @availableYearRange
      """<option value="#{year}">#{year}</options>"""

    """
    <select name="year">
       #{yearOptions.join('')}
    </select>
    """

  selectedYear: ->
    @$('select option:selected').val()

  fetchTeamIndex: =>
    year = @selectedYear()
    $.getJSON("#{apiRoot}/#{year}/index.json").done (teamIds) =>
      @trigger 'fetched-team-index', teamIds


  render: ->
    @$el.html @template()
    this


team      = 'PHI'
startYear = 1992
endYear   = 1994

years = [startYear..endYear]

requests = for year in years
  $.getJSON("#{apiRoot}#{year}/#{team}")

Q.all(requests).done (results) ->
  results


module.exports = {
  YearSelect
}
