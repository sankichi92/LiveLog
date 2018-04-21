var Playlist = function(player, songs, callback) {
    this.player = player;
    this.songs = songs;
    this.current = 0;
    this.callback = callback;
    this.load()
};
Playlist.prototype.load = function () {
    var song = this.songs[this.current];
    this.player.src = song.audio_url;
    this.player.load();
    this.callback(song)
};
Playlist.prototype.play = function () {
    this.player.play()
};
Playlist.prototype.backward = function () {
    this.current--;
    if (this.current < 0) {
        this.current = this.songs.length - 1;
    }
    this.load()
};
Playlist.prototype.forward = function () {
    this.current++;
    if (this.current >= this.songs.length) {
        this.current = 0;
    }
    this.load()
};
Playlist.prototype.getCurrentSong = function () {
    return this.songs[this.current]
};

$(document).on('turbolinks:load', function () {
    var player = $('#playlist');
    if (player.length === 0) {
        return
    }

    var label = $('#playlist-label');

    var playlist = new Playlist(player.get(0), player.data('songs'), function (song) {
        var link_to_song = $('<a></a>', {href: '/songs/' + song.id, text: song.title});
        if (label.data('show-live') === undefined) {
            label.text(song.time_order + ' ').append(link_to_song)
        } else {
            label.html(song.live_title + ' ' + song.time_order + '<br>').append(link_to_song)
        }
    });

    $('#playlist-backward').on('click', function () {
        playlist.backward()
    });

    $('#playlist-forward').on('click', function () {
        playlist.forward()
    });

    player
        .on('play', function () {
            var song = playlist.getCurrentSong();
            gtag('event', 'audio_play', {
                'event_category': 'engagement',
                'event_label': song.id
            })
        })
        .on('ended', function () {
            var song = playlist.getCurrentSong();
            gtag('event', 'audio_end', {
                'event_category': 'engagement',
                'event_label': song.id
            });
            playlist.forward();
            playlist.play()
        })
});
