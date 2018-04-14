$(document).on('turbolinks:load', function () {
    var iTunes = $('#itunes');
    if (iTunes.length === 0) {
        return
    }

    var trackName = iTunes.data('track-name');
    var artistName = iTunes.data('artist-name');

    var searchITunes = function(term, callback) {
        $.ajax({
            url: 'https://itunes.apple.com/search',
            data: {
                term: term,
                country: 'JP',
                media: 'music',
                entity: 'song',
                lang: 'ja_jp'
            },
            dataType: 'json',
            success: callback
        })
    };

    var findAppropriateResult = function(results, trackName, artistName) {
        var result = results.find(function (res) {
            return res.trackName.toLowerCase() === trackName.toLowerCase() && res.artistName.toLowerCase() === artistName.toLowerCase()
        });

        if (result === undefined) {
            result = results.find(function (res) {
                return res.artistName.toLowerCase() === artistName.toLowerCase()
            })
        }

        if (result === undefined) {
            result = results[0]
        }

        return result
    };

    var showResult = function (iTunes, result) {
        iTunes.find('.card-title').text(result.collectionName + ' / ' + result.artistName);
        iTunes.find('.card-subtitle').text(result.trackNumber + ' ' + result.trackName);
        iTunes.find('.img-thumbnail').attr('src', result.artworkUrl100);
        iTunes.find('audio').attr('src', result.previewUrl);
        iTunes.find('a').attr('href', result.trackViewUrl + '&at=1001lKQU&app=itunes');
        iTunes.removeClass('d-none');
    };

    searchITunes(trackName + ' ' + artistName, function(json) {
        if (json.resultCount === 0) {
            return
        }
        var result = findAppropriateResult(json.results, trackName, artistName);
        showResult(iTunes, result)
    })
});
