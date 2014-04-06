crypto = require 'crypto'

Q      = require 'q'
$      = require 'jquery'

team      = 'PHI'
startYear = 1992
endYear   = 1994
apiRoot   = 'http://localhost:8081/v1/seasons/'

years = [startYear..endYear]

requests = for year in years
  $.getJSON("#{apiRoot}#{year}/#{team}")

playerColor = (id) ->
  shasum = crypto.createHash('sha1')
  '#' + shasum.update(id).digest('hex')[0..5]

sizescale = (n) ->
  n or= 1
  n * 20

Q.all(requests).done (results) ->
  results
