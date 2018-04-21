$(document).on('turbolinks:load', function () {
   $('.link').on('click', function () {
       var location = $(this).data('location');
       if (location) {
           Turbolinks.visit(location)
       }
   })
});
