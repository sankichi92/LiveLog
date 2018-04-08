var player;

function onYouTubeIframeAPIReady() {
    player = new YT.Player('player', {
        events: {
            'onStateChange': onPlayerStateChange
        }
    });
}

var played = false;
var ended = false;

function onPlayerStateChange(e) {
    if (e.data == YT.PlayerState.PLAYING && !played) {
        ga('send', 'event', 'Videos', 'play', $('#player').data('song-id'));
        played = true;
    } else if (e.data == YT.PlayerState.ENDED && !ended) {
        ga('send', 'event', 'Videos', 'end', $('#player').data('song-id'));
        ended = true;
    }
}
