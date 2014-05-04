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
      
      $('<div id="anneal_progress" class="progress progress-striped active"><div class="progress-bar" role="progressbar" style="width: 100%"></div></div>').insertBefore("#notice");

      evtSource = new EventSource($(this).attr('href'));

      evtSource.addEventListener('info', function(e) {
        $('#anneal_progress > .progress-bar').text(e.data);
      });
      
      evtSource.addEventListener('done', function(e) {
        evtSource.close();
        window.location.reload();
      });
      
      return;
    });
  }
  $(document).ready(bind_anneal_callback);
  $(document).on('page:load', bind_anneal_callback)
})(jQuery)
