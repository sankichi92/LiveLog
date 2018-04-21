$(document).on('turbolinks:load', function () {
    $('.fb-share').on('click', function () {
        var fb = $(this);
        FB.ui({
            method: 'share',
            mobile_iframe: true,
            hashtag: '#京大アンプラグド',
            href: fb.data('url')
        }, function (response) {
            if (response && !response.error_message) {
                gtag('event', 'share', {
                    'method': 'Facebook',
                    'content_type': fb.data('content-type'),
                    'content_id': fb.data('content-id')
                });
            }
        });
    });
});
