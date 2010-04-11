$(function() {
//  $('#content .article:odd,#content .article-preview:odd').addClass('odd');
//  $('#content .article:even,#content .article-preview:even').addClass('even');
  $(function() {
    $('.images a').lightBox({
      imageLoading: '/images/lightbox-ico-loading.gif',              // (string) Path and the name of the loading icon^
      imageBtnPrev: '/images/lightbox-btn-prev.gif',                 // (string) Path and the name of the prev button image^
      imageBtnNext: '/images/lightbox-btn-next.gif',                 // (string) Path and the name of the next button image^
      imageBtnClose: '/images/lightbox-btn-close.gif',                // (string) Path and the name of the close btn^
      imageBlank: '/images/lightbox-blank.gif'                    // (string) Path and the name of a blank image (one pixel)^
    });
  });
});
