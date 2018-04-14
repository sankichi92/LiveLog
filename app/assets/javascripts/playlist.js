$(document).on('turbolinks:load', function () {
    var player = $('#playlist');
    if (player.length === 0) {
        return
    }

    var playlist = {
        player: player.get(0),
        label: $('#playlist-label'),
        audios: player.data('audios'),
        i: 0,
        play: function () {
            this.player.play()
        },
        backward: function () {
            this.i--;
            if (this.i < 0) {
                this.i = this.audios.length - 1;
            }
            this.init()
        },
        forward: function () {
            this.i++;
            if (this.i >= this.audios.length) {
                this.i = 0;
            }
            this.init()
        },
        init: function () {
            this.label.text(this.audios[this.i].order + ' ' + this.audios[this.i].title);
            this.player.src = this.audios[this.i].audio_url;
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
