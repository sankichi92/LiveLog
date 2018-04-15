$(document).on('turbolinks:load', function () {
    var player = $('#playlist');
    if (player.length === 0) {
        return
    }

    var playlist = {
        player: player.get(0),
        label: $('#playlist-label'),
        songs: player.data('songs'),
        i: 0,
        play: function () {
            this.player.play()
        },
        backward: function () {
            this.i--;
            if (this.i < 0) {
                this.i = this.songs.length - 1;
            }
            this.init()
        },
        forward: function () {
            this.i++;
            if (this.i >= this.songs.length) {
                this.i = 0;
            }
            this.init()
        },
        init: function () {
            var song = this.songs[this.i];
            if (this.label.data('show-live') === undefined) {
                this.label.text(song.order + ' ' + song.title);
            } else {
                this.label.html(song.live_title + ' ' + song.order + '<br>' + song.title);
            }
            this.player.src = song.audio_url;
            this.player.load()
        }
    };

    playlist.init();

    $('#playlist-backward').on('click', function () {
        playlist.backward()
    });

    $('#playlist-forward').on('click', function () {
        playlist.forward()
    });

    player.on('ended', function () {
        playlist.forward();
        playlist.play()
    });
});
