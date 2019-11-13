window.dataLayer = window.dataLayer || [];

function gtag() {
    dataLayer.push(arguments);
}

gtag('js', new Date());

$(document).on('turbolinks:load', function () {
    gtag('config', 'UA-56294602-1', {
        'page_path': window.location.pathname,
        'link_attribution': true,
        'user_id': $('body').data('user-id')
    });
});
