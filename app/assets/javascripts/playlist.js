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
        played: false,
        ended: false,
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

            var link_to_song = $('<a></a>', {href: '/songs/' + song.id, text: song.title});

            if (this.label.data('show-live') === undefined) {
                this.label.text(song.time_order + ' ').append(link_to_song);
            } else {
                this.label.html(song.live_title + ' ' + song.time_order + '<br>').append(link_to_song);
            }

            this.player.src = song.audio_url;
            this.player.load();

            this.played = false;
            this.ended = false;
        },
        sendPlayLog: function () {
            if (!this.played) {
                ga('send', 'event', 'Audio', 'play', this.songs[this.i]);
                this.played = true
            }
        },
        sendEndLog: function () {
            if (!this.ended) {
                ga('send', 'event', 'Audio', 'end', this.songs[this.i]);
                this.ended = true
            }
        }
    };

    playlist.init();

    $('#playlist-backward').on('click', function () {
        playlist.backward()
    });

    $('#playlist-forward').on('click', function () {
        playlist.forward()
    });

    player.on('play', function () {
        playlist.sendPlayLog();
    });

    player.on('ended', function () {
        playlist.sendEndLog();
        playlist.forward();
        playlist.play()
    });
});
