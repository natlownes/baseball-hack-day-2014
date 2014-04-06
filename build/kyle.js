$(document).ready(function() {
  $('td > div').each(function() {
    $(this).qtip({
      content: {
        text: $(this).children('.info')
      },
      position: {
        my: 'top center',  // Position my top left...
        at: 'bottom center'
      }
    });
  });
});
