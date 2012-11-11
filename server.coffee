express = require('express')
http = require('http')
path = require('path')
app = express()

{p} = require 'sys'

## MODEL

{Nohm} = require('nohm')
redis = require('redis')

User = Nohm.model 'User',
  # has many feeds
  idGenerator: 'increment'
  properties:
    email:
      type: 'string'
      unique: true
      index: true
      validations: ['email']
    visits:
      type: (value, key, old) -> old + value
      defaultValue: 0
      index: true
    created_at:
      type: 'timestamp'
      defaultValue: -> new Date()
  methods:
    full_name: -> "#{@p('name')} (#{@p('email')})"

Feed = Nohm.model 'Feed',
  # belong to User
  # has many messages
  idGenerator: 'increment'
  properties:
    name:
      type: 'string'
      validations: ['notEmpty']
    created_at:
      type: 'timestamp'
      defaultValue: -> new Date()
  methods:
    get_messages: (err_cb, cb) ->
      @getAll 'Message', (err, message_ids) ->
        messages = []
        if message_ids.length == 0
          cb(messages)
        for message_id in message_ids
          Message.load message_id, (err) ->
            messages.push @
            if message_ids.length == messages.length
              cb(messages)

Message = Nohm.model 'Message',
  # belong to Feed
  idGenerator: 'increment'
  properties:
    body:
      type: 'string'
    resolved:
      type: 'boolean'
    created_at:
      type: 'timestamp'
      defaultValue: -> new Date()



## MIDDLEWARE

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

  client = redis.createClient()
  Nohm.setClient(client)

app.configure 'production', ->
  client = redis.createClient(6379, 'nodejitsudb5865048577.redis.irstack.com', parser: 'javascript')
  client.auth 'nodejitsudb5865048577.redis.irstack.com:f327cfe980c971946e80b8e975fbebb4', (err) ->
    throw err if err
    Nohm.setClient(client)

## SERVER

app.get '/', (req, res) -> res.render 'index', title: 'Statusus'
app.get '/pricing', (req, res) -> res.render 'pricing', title: 'Statusus'
app.get '/about', (req, res) -> res.render 'about', title: 'Statusus'
app.get '/login', (req, res) -> res.render 'login', title: 'Statusus'

app.get '/feeds', (req, res, next) ->
  Feed.find (err, feed_ids) ->
    next(err) if err
    feeds = []
    if feed_ids.length == 0
      return res.render 'feeds', title: 'Feeds', feeds: feeds
    for feed_id in feed_ids
      Feed.load feed_id, (err) ->
        return next(err) if err
        @get_messages next, (messages) =>
          @messages = messages
          feeds.push @
          if feed_ids.length == feeds.length
            res.render 'feeds', title: 'Feeds', feeds: feeds

app.post '/feeds', (req, res, next) ->
  name = req.param('name')
  feed = Nohm.factory('Feed')
  feed.p(name: name)
  feed.save (err) ->
    if err == 'invalid'
      next(feed.errors)
    else if err
      next(err)
    else
      res.redirect '/feeds'

app.post '/feeds/:feed_id', (req, res, next) ->
  Feed.load req.param('feed_id'), (err) ->
    return next(err) if err
    feed = @

    body = req.param('body')
    resolved = req.param('status') == 'resolved'
    message = Nohm.factory('Message')
    message.p({body, resolved})
    message.save (err) ->
      if err == 'invalid'
        next(message.errors)
      else if err
        next(err)
      else
        feed.link message
        feed.save ->
          res.status 201
          res.json data: message.allProperties()

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
