#= require angular
#= require angular-touch
#= require angularjs/rails/resource
#= require_self


angular.module('statusus', ['ngTouch', 'rails'])

  .config ($httpProvider) ->
    token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = token

  .factory('Message', ['railsResourceFactory', (railsResourceFactory) ->
    railsResourceFactory(url: '/messages', name: 'message')
  ])

  .controller('MainCtrl', ['$scope', 'Message', ($scope, Message) ->
    newMessage = ->
      {status: 0}
    $scope.messages = []
    Message.query().then (messages) ->
      $scope.messages = messages
    $scope.message = newMessage()
    $scope.createNewMessage = ->
      message = new Message(message: $scope.message)
      $scope.messages.unshift message
      $scope.message = newMessage()
      message.create()
  ])
