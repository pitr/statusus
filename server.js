// Generated by IcedCoffeeScript 1.3.3g
(function() {
  var Feed, Message, Nohm, RedisStore, User, app, express, http, iced, p, path, redis, redis_client, uuid, __iced_k, __iced_k_noop;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  express = require('express');

  RedisStore = require('connect-redis')(express);

  http = require('http');

  path = require('path');

  app = express();

  uuid = require('node-uuid');

  p = require('sys').p;

  Nohm = require('nohm').Nohm;

  redis = require('redis');

  User = Nohm.model('User', {
    idGenerator: 'increment',
    properties: {
      email: {
        type: 'string',
        unique: true,
        index: true,
        validations: ['email']
      },
      created_at: {
        type: 'timestamp'
      },
      dashboard_udid: {
        type: 'string',
        index: true
      }
    },
    methods: {
      create: function(data, next, cb) {
        this.p(data);
        this.p('created_at', +new Date());
        this.p('dashboard_udid', uuid.v1());
        return this.save(function(err) {
          if (err === 'invalid') {
            return next(this.errors);
          } else if (err) {
            return next(err);
          } else {
            return cb(this);
          }
        });
      },
      get_feeds: function(err_cb, cb) {
        return this.getAll('Feed', function(err, feed_ids) {
          var feed_id, feeds, _i, _len, _results;
          feeds = [];
          if (feed_ids.length === 0) cb(feeds);
          _results = [];
          for (_i = 0, _len = feed_ids.length; _i < _len; _i++) {
            feed_id = feed_ids[_i];
            _results.push(Feed.load(feed_id, function(err) {
              feeds.push(this);
              if (feed_ids.length === feeds.length) return cb(feeds);
            }));
          }
          return _results;
        });
      }
    }
  });

  Feed = Nohm.model('Feed', {
    idGenerator: 'increment',
    properties: {
      name: {
        type: 'string',
        validations: ['notEmpty']
      },
      created_at: {
        type: 'timestamp'
      }
    },
    methods: {
      create: function(data, next, cb) {
        this.p(data);
        this.p('created_at', +new Date());
        return this.save(function(err) {
          if (err === 'invalid') {
            return next(this.errors);
          } else if (err) {
            return next(err);
          } else {
            return cb(this);
          }
        });
      },
      get_messages: function(err_cb, cb) {
        return this.getAll('Message', function(err, message_ids) {
          var message_id, messages, _i, _len, _results;
          messages = [];
          if (message_ids.length === 0) cb(messages);
          _results = [];
          for (_i = 0, _len = message_ids.length; _i < _len; _i++) {
            message_id = message_ids[_i];
            _results.push(Message.load(message_id, function(err) {
              messages.push(this);
              if (message_ids.length === messages.length) return cb(messages);
            }));
          }
          return _results;
        });
      }
    }
  });

  Message = Nohm.model('Message', {
    idGenerator: 'increment',
    properties: {
      body: {
        type: 'string'
      },
      resolved: {
        type: 'boolean'
      },
      created_at: {
        type: 'timestamp'
      }
    },
    methods: {
      create: function(data, next, cb) {
        this.p(data);
        this.p('created_at', +new Date());
        return this.save(function(err) {
          if (err === 'invalid') {
            return next(this.errors);
          } else if (err) {
            return next(err);
          } else {
            return cb(this);
          }
        });
      }
    }
  });

  redis_client = null;

  app.configure('development', function() {
    redis_client = redis.createClient();
    return Nohm.setClient(redis_client);
  });

  app.configure('production', function() {
    redis_client = redis.createClient(6379, 'nodejitsudb5865048577.redis.irstack.com', {
      parser: 'javascript'
    });
    return redis_client.auth('nodejitsudb5865048577.redis.irstack.com:f327cfe980c971946e80b8e975fbebb4', function(err) {
      if (err) throw err;
      return Nohm.setClient(redis_client);
    });
  });

  app.configure(function() {
    app.set('port', process.env.PORT || 8000);
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.use(express.favicon());
    app.use(express.logger('dev'));
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser('mysecrethere'));
    app.use(express.session({
      store: new RedisStore({
        client: redis_client
      })
    }));
    app.use(require('less-middleware')({
      src: "" + __dirname + "/less",
      dest: "" + __dirname + "/public/stylesheets",
      prefix: '/stylesheets'
    }));
    app.use(express["static"](path.join(__dirname, 'public')));
    app.use(function(req, res, next) {
      req.user = null;
      res.locals.user = null;
      if (req.session.user_id) {
        return User.load(req.session.user_id, function(err) {
          if (err) {
            req.session.user_id = null;
          } else {
            req.user = this;
            res.locals.user = this;
          }
          return next();
        });
      } else {
        return next();
      }
    });
    return app.use(app.router);
  });

  app.configure('development', function() {
    return app.use(express.errorHandler());
  });

  app.get('/', function(req, res, next) {
    return res.render('index', {
      title: 'Statusus'
    });
  });

  app.get('/pricing', function(req, res, next) {
    return res.render('pricing', {
      title: 'Statusus'
    });
  });

  app.get('/about', function(req, res, next) {
    return res.render('about', {
      title: 'Statusus'
    });
  });

  app.get('/logout', function(req, res, next) {
    delete req.session.user_id;
    return res.redirect('/');
  });

  app.post('/', function(req, res, next) {
    var email;
    if (req.session.user_id) {
      res.redirect('/feeds');
      return;
    }
    email = req.param('email');
    return User.find({
      email: email
    }, function(err, user_ids) {
      var user;
      if (err) {
        return next(err);
      } else if (user_ids.length > 0) {
        req.session.user_id = user_ids[0];
        return res.redirect('/feeds');
      } else {
        user = Nohm.factory('User');
        return user.create({
          email: email
        }, next, function() {
          req.session.user_id = user.id;
          return res.redirect('/feeds');
        });
      }
    });
  });

  app.get('/dashboard/:udid', function(req, res, next) {
    var dashboard_udid;
    dashboard_udid = req.param('udid');
    return User.find({
      dashboard_udid: dashboard_udid
    }, function(err, user_ids) {
      if (user_ids.length > 0) {
        return User.load(user_ids[0], function(err) {
          var user;
          if (err) {
            return next(err);
          } else {
            user = this;
            return user.get_feeds(next, function(feeds) {
              var feed, messages, ___iced_passed_deferral, __iced_deferrals, __iced_k,
                _this = this;
              __iced_k = __iced_k_noop;
              ___iced_passed_deferral = iced.findDeferral(arguments);
              (function(__iced_k) {
                var _i, _len, _ref, _results, _while;
                _ref = feeds;
                _len = _ref.length;
                _i = 0;
                _results = [];
                _while = function(__iced_k) {
                  var _break, _continue, _next;
                  _break = function() {
                    return __iced_k(_results);
                  };
                  _continue = function() {
                    return iced.trampoline(function() {
                      ++_i;
                      return _while(__iced_k);
                    });
                  };
                  _next = function(__iced_next_arg) {
                    _results.push(__iced_next_arg);
                    return _continue();
                  };
                  if (!(_i < _len)) {
                    return _break();
                  } else {
                    feed = _ref[_i];
                    (function(__iced_k) {
                      __iced_deferrals = new iced.Deferrals(__iced_k, {
                        parent: ___iced_passed_deferral,
                        filename: "server.coffee"
                      });
                      feed.get_messages(next, __iced_deferrals.defer({
                        assign_fn: (function() {
                          return function() {
                            return messages = arguments[0];
                          };
                        })(),
                        lineno: 198
                      }));
                      __iced_deferrals._fulfill();
                    })(function() {
                      return _next(feed.messages = messages);
                    });
                  }
                };
                _while(__iced_k);
              })(function() {
                return res.render('dashboard', {
                  title: 'Dashboard',
                  feeds: feeds
                });
              });
            });
          }
        });
      } else {
        return next(err);
      }
    });
  });

  app.all('*', function(req, res, next) {
    if (req.user) {
      return next();
    } else {
      return res.redirect('/');
    }
  });

  app.get('/feeds', function(req, res, next) {
    return req.user.get_feeds(next, function(feeds) {
      var feed, messages, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      (function(__iced_k) {
        var _i, _len, _ref, _results, _while;
        _ref = feeds;
        _len = _ref.length;
        _i = 0;
        _results = [];
        _while = function(__iced_k) {
          var _break, _continue, _next;
          _break = function() {
            return __iced_k(_results);
          };
          _continue = function() {
            return iced.trampoline(function() {
              ++_i;
              return _while(__iced_k);
            });
          };
          _next = function(__iced_next_arg) {
            _results.push(__iced_next_arg);
            return _continue();
          };
          if (!(_i < _len)) {
            return _break();
          } else {
            feed = _ref[_i];
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "server.coffee"
              });
              feed.get_messages(next, __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    return messages = arguments[0];
                  };
                })(),
                lineno: 217
              }));
              __iced_deferrals._fulfill();
            })(function() {
              return _next(feed.messages = messages);
            });
          }
        };
        _while(__iced_k);
      })(function() {
        return res.render('feeds', {
          title: 'Feeds',
          feeds: feeds,
          host: "" + req.protocol + "://" + req.headers.host
        });
      });
    });
  });

  app.post('/feeds', function(req, res, next) {
    var feed, name;
    name = req.param('name');
    feed = Nohm.factory('Feed');
    return feed.create({
      name: name
    }, next, function() {
      req.user.link(feed);
      return req.user.save(function() {
        return res.redirect('/feeds');
      });
    });
  });

  app.post('/feeds/:feed_id', function(req, res, next) {
    return Feed.load(req.param('feed_id'), function(err) {
      var body, feed, message, resolved;
      if (err) return next(err);
      feed = this;
      body = req.param('body');
      resolved = req.param('status') === 'resolved';
      message = Nohm.factory('Message');
      return message.create({
        body: body,
        resolved: resolved
      }, next, function() {
        feed.link(message);
        return feed.save(function() {
          return res.redirect('/feeds');
        });
      });
    });
  });

  http.createServer(app).listen(app.get('port'), function() {
    return console.log("Express server listening on port " + (app.get('port')));
  });

}).call(this);