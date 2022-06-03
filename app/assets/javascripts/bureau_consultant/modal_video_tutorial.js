$(function() {
  /* Stop embedded youtube video when modal closed */
  $(".modal-video-tutorial").on('hidden.bs.modal', function (e) {
    $(".modal-video-tutorial iframe").remove();
    $(this).find('.play-button').show();
    $(this).find('.video-thumbnail').show();
  });


  /* “Lazy Load” Embedded YouTube Videos */
  var youtube = document.querySelectorAll(".youtube");
  for (var i = 0; i < youtube.length; i++) {
    var source = "https://img.youtube.com/vi/" + youtube[i].dataset.embed + "/sddefault.jpg";
    var image = new Image();
    image.src = source;
    image.setAttribute('class', 'video-thumbnail');
    image.addEventListener("load", function () {
      youtube[i].appendChild(image);
    }(i));
    youtube[i].addEventListener("click", function () {
      var iframe = document.createElement("iframe");
      iframe.setAttribute("frameborder", "0");
      iframe.setAttribute("allowfullscreen", "");
      iframe.setAttribute("src", "https://www.youtube.com/embed/" + this.dataset.embed + "?showinfo=0&autoplay=1");
      this.appendChild(iframe);

      $(this).find('.play-button').hide();
      $(this).find('.video-thumbnail').hide();
    });
  }
});