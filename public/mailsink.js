headers = {
  
  show: function() {
      $(".headers").show('fast');
      $("#header-control").replaceWith(
          $('<h2 id="header-control">Hide Headers</h2>').click(function() {
              headers.hide();
          })
      );
  },
  
  hide: function() {
      $(".headers").hide('fast');
      $("#header-control").replaceWith(
          $('<h2 id="header-control">Show Headers</h2>').click(function() {
              headers.show();
          })
      );
  }
};

$(document).ready(function() {
    headers.hide();
});
