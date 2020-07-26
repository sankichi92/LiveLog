import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['title', 'subTitle', 'artwork', 'audio', 'link'];

  async connect() {
    const searchResult = await this._fetchSearchResult();
    if (searchResult.resultCount === 0) {
      return;
    }
    const result = this._findAppropriateResult(searchResult.results);
    this._showResult(result);
  }

  get trackName() {
    return this.data.get('trackName');
  }

  get artistName() {
    return this.data.get('artistName');
  }

  _fetchSearchResult() {
    const encodedTrackName = encodeURIComponent(this.trackName);
    const encodedArtistName = encodeURIComponent(this.artistName);
    return fetch(`https://itunes.apple.com/search?term=${encodedTrackName}+${encodedArtistName}&country=JP&media=music&entity=song&lang=ja_jp`, {
      redirect: 'error',
    }).then((response) => {
      if (response.ok) {
        return response.json();
      } else {
        return Promise.reject(new Error(`${response.status}: ${response.statusText}`));
      }
    });
  }

  _findAppropriateResult(results) {
    let result = results.find((res) => {
      return res.trackName.toLowerCase() === this.trackName.toLowerCase() && res.artistName.toLowerCase() === this.artistName.toLowerCase();
    });

    if (result === undefined) {
      result = results.find((res) => res.artistName.toLowerCase() === this.artistName.toLowerCase());
    }

    if (result === undefined) {
      result = results[0];
    }

    return result;
  }

  _showResult(result) {
    this.subTitleTarget.textContent = `${result.collectionName} ${result.trackNumber}`;
    this.titleTarget.textContent = `${result.trackName} / ${result.artistName}`;

    this.artworkTarget.setAttribute('src', result.artworkUrl100);
    this.audioTarget.setAttribute('src', result.previewUrl);

    this.linkTargets.forEach((element) => element.setAttribute('href', `${result.trackViewUrl}&at=1001lKQU&app=itunes`));

    this.element.classList.remove('d-none');
  }
}
