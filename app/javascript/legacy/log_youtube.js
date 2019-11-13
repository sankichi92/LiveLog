function onYouTubeIframeAPIReady() {
    var songId = $('#youtube-player').data('song-id');
    new YT.Player('youtube-player', {
        events: {
            'onStateChange': function (e) {
                if (e.data == YT.PlayerState.PLAYING) {
                    gtag('event', 'video_play', {
                        'event_category': 'engagement',
                        'event_label': songId
                    });
                } else if (e.data == YT.PlayerState.ENDED) {
                    gtag('event', 'video_end', {
                        'event_category': 'engagement',
                        'event_label': songId
                    });
                }
            }
        }
    });
}
