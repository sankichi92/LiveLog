$(document).on('turbolinks:load', function () {
   $('.link').on('click', function () {
       var location = $(this).data('href');
       if (location) {
           Turbolinks.visit(location)
       }
   })
});
