function fetchAndShowSongFromITunes(songName, artistName) {
    $.ajax({
        url: 'https://itunes.apple.com/search',
        data: {
            term: songName + ' ' + artistName,
            country: 'JP',
            media: 'music',
            entity: 'song',
            lang: 'ja_jp'
        },
        dataType: 'json'
    }).done(function (json) {
        if (json.resultCount === 0) {
            return;
        }

        var results = json.results;
        var result = results.find(function (result) {
            return result.trackName === songName && result.artistName === artistName;
        });

        if (!result) {
            result = results[0];
        }

        $('#itunes-title').text(result.collectionName + ' / ' + result.artistName);
        $('#itunes-track').text(result.trackNumber + ' ' + result.trackName);
        $('#itunes-artwork').attr('src', result.artworkUrl100);
        $('#itunes-preview').attr('src', result.previewUrl);
        $('.itunes-link').attr('href', result.trackViewUrl + '&at=1001lKQU&app=itunes');
        $('#itunes').removeClass('d-none');
    })
}
