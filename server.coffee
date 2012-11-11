express = require('express')
http = require('http')
path = require('path')
app = express()

uuid = require('node-uuid')
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
    created_at:
      type: 'timestamp'
    dashboard_udid:
      type: 'string'
      index: true
  methods:
    create: (data, next, cb) ->
      @p(data)
      @p('created_at', +new Date())
      @p('dashboard_udid', uuid.v1())
      @save (err) ->
        if err == 'invalid'
          next(@errors)
        else if err
          next(err)
        else
          cb(@)
    get_feeds: (err_cb, cb) ->
      @getAll 'Feed', (err, feed_ids) ->
        feeds = []
        if feed_ids.length == 0
          cb(feeds)
        for feed_id in feed_ids
          Feed.load feed_id, (err) ->
            feeds.push @
            if feed_ids.length == feeds.length
              cb(feeds)

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
  methods:
    create: (data, next, cb) ->
      @p(data)
      @p('created_at', +new Date())
      @save (err) ->
        if err == 'invalid'
          next(@errors)
        else if err
          next(err)
        else
          cb(@)
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
  methods:
    create: (data, next, cb) ->
      @p(data)
      @p('created_at', +new Date())
      @save (err) ->
        if err == 'invalid'
          next(@errors)
        else if err
          next(err)
        else
          cb(@)


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
  app.use require('less-middleware')({ src: __dirname + '/public' })
  app.use express.static(path.join(__dirname, 'public'))
  app.use (req, res, next) ->
    # try to authenticate, ignore failure silently
    req.user = null
    res.locals.user = null
    if req.session.user_id
      User.load req.session.user_id, (err) ->
        if err
          req.session.user_id = null
        else
          req.user = @
          res.locals.user = @
        next()
    else
      next()
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler()

  client = redis.createClient()
  Nohm.setClient(client)

app.configure 'production', ->
  client = redis.createClient(6379, 'nodejitsudb5865048577.redis.irstack.com', parser: 'javascript')
  client.auth 'nodejitsudb5865048577.redis.irstack.com:f327cfe980c971946e80b8e975fbebb4', (err) ->
    throw err if err
    Nohm.setClient(client)

## HELPERS

## SERVER

app.get '/', (req, res, next) ->
  res.render 'index', title: 'Statusus'

app.get '/pricing', (req, res, next) -> res.render 'pricing', title: 'Statusus'
app.get '/about', (req, res, next) -> res.render 'about', title: 'Statusus'

app.get '/logout', (req, res, next) ->
  delete req.session.user_id
  res.redirect '/'

app.post '/', (req, res, next) ->
  if req.session.user_id
    res.redirect '/feeds'
    return

  email = req.param('email')
  User.find {email}, (err, user_ids) ->
    if err
      next(err)
    else if user_ids.length > 0
      # found a user
      req.session.user_id = user_ids[0]
      res.redirect '/feeds'
    else
      user = Nohm.factory('User')
      user.create {email}, next, ->
        req.session.user_id = user.id
        res.redirect '/feeds'


app.get '/dashboard/:udid', (req, res, next) ->
  dashboard_udid = req.param('udid')
  User.find {dashboard_udid}, (err, user_ids) ->
    if user_ids.length > 0
      # found a user
      User.load user_ids[0], (err) ->
        if err
          next(err)
        else
          user = @
          user.get_feeds next, (feeds) ->
            for feed in feeds
              await feed.get_messages next, defer(messages)
              feed.messages = messages
            res.render 'dashboard', title: 'Dashboard', feeds: feeds
    else
      next(err)


#---- all requests must be authenticated beyond this point ----#

app.all '*', (req, res, next) ->
  if req.user
    next()
  else
    res.redirect '/'


app.get '/feeds', (req, res, next) ->
  req.user.get_feeds next, (feeds) ->
    for feed in feeds
      await feed.get_messages next, defer(messages)
      feed.messages = messages
    res.render 'feeds', title: 'Feeds', feeds: feeds, host: "#{req.protocol}://#{req.headers.host}"

app.post '/feeds', (req, res, next) ->
  name = req.param('name')
  feed = Nohm.factory('Feed')
  feed.create name: name, next, ->
    req.user.link(feed)
    req.user.save ->
      # res.status 201
      # res.json data: feed.allProperties()
      res.redirect '/feeds'

app.post '/feeds/:feed_id', (req, res, next) ->
  Feed.load req.param('feed_id'), (err) ->
    # TODO: check if feed belongs to user
    return next(err) if err
    feed = @

    body = req.param('body')
    resolved = req.param('status') == 'resolved'
    message = Nohm.factory('Message')
    message.create {body, resolved}, next, ->
      feed.link message
      feed.save ->
        # res.status 201
        # res.json data: message.allProperties()
        res.redirect '/feeds'

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
