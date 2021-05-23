import React from 'react';
import ReactDOM from 'react-dom';
import { ItunesAd } from 'ItunesAd';

document.addEventListener('DOMContentLoaded', () => {
  const itunesAd = document.getElementById('itunes-ad');
  if (itunesAd && itunesAd.dataset.searchTerm) {
    ReactDOM.render(<ItunesAd searchTerm={itunesAd.dataset.searchTerm}></ItunesAd>, itunesAd);
  }
});
