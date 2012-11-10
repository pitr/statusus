express = require('express')
http = require('http')
path = require('path')
# redis = require('redis')
# db = redis.createClient()
app = express()

app.configure ->
  app.set 'port', process.env.PORT || 8000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser('mysecrethere')
  app.use express.session()
  app.use app.router
  app.use require('less-middleware')({ src: __dirname + '/public' })
  app.use express.static(path.join(__dirname, 'public'))

app.configure 'development', ->
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.render 'index', title: 'Statusus'

app.get '/feeds', (req, res) ->
  res.render 'feeds', title: 'Feeds'


http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
