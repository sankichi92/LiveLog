function onYouTubeIframeAPIReady() {
    var played = false;
    var ended = false;
    new YT.Player('player', {
        events: {
            'onStateChange': function (e) {
                if (e.data == YT.PlayerState.PLAYING && !played) {
                    ga('send', 'event', 'Videos', 'play', $('#player').data('song-id'));
                    played = true;
                } else if (e.data == YT.PlayerState.ENDED && !ended) {
                    ga('send', 'event', 'Videos', 'end', $('#player').data('song-id'));
                    ended = true;
                }
            }
        }
    });
}
