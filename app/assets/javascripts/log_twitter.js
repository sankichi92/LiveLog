$(document).on('turbolinks:load', function () {
    $('.twitter-share').on('click', function () {
        gtag('event', 'share', {
            'method': 'Twitter',
            'content_type': $(this).data('content-type'),
            'content_id': $(this).data('content-id')
        });
    });
});
