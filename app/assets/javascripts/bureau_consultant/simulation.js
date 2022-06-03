$(document).ready(function () {
  $(".to-step-2").click(function () {
    next_step(1);
  });

  $('.to-step-3').click(function (){
    next_step(2);
  });

  $('.to-last-step').click(function () {
    next_step(3, true);
    show_summary();
  });

  $('.recall').click(function (){
    show_element($('.recall-success'));
    hidden_element($('.personal-simulation'));
  });

  $('.icon-close').click(function () {
    $('.recall-success').hide();
  });
});

function next_step(i, last) {
  $('.choice-'+i+'-form').addClass('display-none');
  $('.choice-'+i+' .bullet-circle').addClass('bullet-circle-done');
  $('.choice-'+i+' .bullet-label').addClass('bullet-label-done');
  $('.choice-'+i).removeClass('simulation-left-accodian-bg')


  if(!last) {
      $('.choice-'+(i+1)+'-form').removeClass('display-none');
      $('.choice-'+(i+1)+' .bullet-circle' ).removeClass('bullet-circle-inactive');
      $('.choice-'+(i+1)+' .bullet-label' ).removeClass('bullet-label-inactive');
      $('.choice-'+(i+1)).addClass('simulation-left-accodian-bg');
  }
}

function show_summary() {
  $('.summary').removeClass('display-none');
  $('.summary-md').removeClass('display-none');
  $('.summary-btn').removeClass('display-none');
  $('.summary-btn-md').removeClass('display-none');
}