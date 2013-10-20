#= require jquery
#= require jquery_ujs
#= require_self
#= require_tree .

$ ->
  $('.component_status').on 'change', ->
    $radio = $(@)
    status = $radio.val()
    component_id = $radio.data('component-id')
    $.post "/components/#{component_id}/status", {status}
