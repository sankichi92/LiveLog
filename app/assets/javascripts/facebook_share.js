$(document).on('turbolinks:load', function () {
    $('.fb-share').click(function () {
        var url = $(this).data('url');
        FB.ui({
            method: 'share',
            mobile_iframe: true,
            hashtag: '#京大アンプラグド',
            href: url
        }, function (response) {
            if (response && !response.error_message) {
                var path = new URL(url).pathname;
                ga('send', 'social', 'Facebook', 'share', path);
            }
        });
    });
});
