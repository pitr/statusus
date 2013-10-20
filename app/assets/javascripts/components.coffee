$ ->
  $('.component_status').on 'change', ->
    $radio = $(@)
    status = $radio.val()
    component_id = $radio.data('component-id')
    $.post "/components/#{component_id}/status", {status}
