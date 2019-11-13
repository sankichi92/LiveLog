$(document).on('turbolinks:load', function () {
    $('.gtag-audio')
        .on('play', function () {
            gtag('event', 'audio_play', {
                'event_category': 'engagement',
                'event_label': $(this).data('song-id')
            });
        })
        .on('ended', function () {
            gtag('event', 'audio_end', {
                'event_category': 'engagement',
                'event_label': $(this).data('song-id')
            });
        });
});
