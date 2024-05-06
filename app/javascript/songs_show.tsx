import React from 'react';
import { createRoot } from 'react-dom/client';
import { ItunesAd } from './components/ItunesAd';

document.addEventListener('DOMContentLoaded', () => {
  const itunesAd = document.getElementById('itunes-ad');
  if (itunesAd && itunesAd.dataset.searchTerm) {
    const root = createRoot(itunesAd);
    root.render(<ItunesAd searchTerm={itunesAd.dataset.searchTerm}></ItunesAd>);
  }
});
