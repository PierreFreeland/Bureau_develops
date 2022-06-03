$(document).ready(function(){
  $('[data-toggle="submit"]').click(function() {
    $($(this).attr('data-target')).submit();
  });
});
