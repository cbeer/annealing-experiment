// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .

(function($) {
  function bind_anneal_callback() {
    $('#anneal').on('click', function(event) {
      event.preventDefault();
      
      if ($('#anneal_progress').length > 0) {
        return false;
      }

      $('<div id="anneal_progress" class="progress progress-striped active"><div class="progress-bar" role="progressbar" style="width: 0%"></div></div>').insertBefore("#notice");

      evtSource = new EventSource($(this).attr('href'));

      evtSource.addEventListener('info', function(e) {
        var matches = e.data.match(/Iteration (\d+)/);
        if (typeof matches[1] != "undefined") {
          $('#anneal_progress > .progress-bar').css('width', 100*(matches[1]/2500) + "%").text(Math.round(100*(matches[1]/2500)) + "%");
        }
      });
      
      evtSource.addEventListener('best', function(e) {
        var matches = e.data.match(/energy (.*):/);
        if (typeof matches[1] != "undefined") {
          $('.energy').text("energy: " + Math.round(matches[1]));
        }
      });
      
      evtSource.addEventListener('best_state', function(e) {
        var events = $.parseJSON(e.data);
        $.each(events, function(i,e) {
          var $ev_div = $('.event[data-event-id="' + e.event_id + '"]');
          $ev_div.find('time').text(e.localized_time);
          var cell = $('.row[data-time="' + e.localized_time + '"]').find('.col-room[data-room-id="' + e.room_id + '"]');
          cell.append($ev_div);
        });
      });
      
      
      
      evtSource.addEventListener('done', function(e) {
        evtSource.close();
        $('#anneal_progress').remove();
        window.location.reload();
      });
      
      return;
    });
  }
  $(document).ready(bind_anneal_callback);
  $(document).on('page:load', bind_anneal_callback)
})(jQuery)
