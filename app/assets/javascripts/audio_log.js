$(document).on('turbolinks:load', function () {
    var audio = $('.ga-audio');
    if (audio.length === 0) {
        return
    }

    var songId = audio.data('song-id');
    var played = false;
    var ended = false;

    audio.on('play', function () {
        if (!played) {
            ga('send', 'event', 'Audio', 'play', songId);
            played = true
        }
    });

    audio.on('ended', function () {
        if (!ended) {
            ga('send', 'event', 'Audio', 'end', songId);
            ended = true
        }
    })
});
