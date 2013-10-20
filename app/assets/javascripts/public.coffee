#= require jquery
#= require turbolinks
#= require rails-timeago-all

setInterval(->
  Turbolinks.visit('/')
, 15000)
