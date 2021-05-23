import React, { useEffect, useState } from 'react';
import { Card, Image, Media } from 'react-bootstrap';

type Props = {
  searchTerm: string;
};

type ItunesSearchResult = {
  resultCount: number;
  results: ItunesSong[];
};

type ItunesSong = {
  artistName: string;
  collectionName: string;
  trackName: string;

  artistViewUrl: string;
  collectionViewUrl: string;
  trackViewUrl: string;

  previewUrl: string;
  artworkUrl100: string;

  trackNumber: number;
};

export const ItunesAd: React.FC<Props> = ({ searchTerm }: Props) => {
  const [itunesSong, setItunesSong] = useState<ItunesSong | null>(null);

  useEffect(() => {
    (async () => {
      // https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
      const itunesSearchParams = new URLSearchParams();
      itunesSearchParams.append('term', searchTerm);
      itunesSearchParams.append('country', 'JP');
      itunesSearchParams.append('media', 'music');
      itunesSearchParams.append('entity', 'song');
      itunesSearchParams.append('limit', '1');
      itunesSearchParams.append('lang', 'ja_jp');

      const itunesSearchURL = new URL('https://itunes.apple.com/search');
      itunesSearchURL.search = itunesSearchParams.toString();

      const response = await fetch(itunesSearchURL.toString());
      if (!response.ok) {
        throw new Error(`Failed GET ${itunesSearchURL} (${response.status} ${response.statusText})`);
      }

      const searchResult = (await response.json()) as ItunesSearchResult;
      if (searchResult.resultCount > 0) {
        setItunesSong(searchResult.results[0]);
      }
    })();
  }, [searchTerm]);

  if (itunesSong === null) {
    return null;
  }

  // https://affiliate.itunes.apple.com/resources/documentation/basic_affiliate_link_guidelines_for_the_phg_network/
  function appendAffiliateParam(url: string): string {
    const affiliateURL = new URL(url);
    affiliateURL.searchParams.append('app', 'music');
    affiliateURL.searchParams.append('at', '1001lKQU');
    return affiliateURL.toString();
  }

  return (
    <Card className="mb-3">
      <Card.Body>
        <Media className="align-items-center">
          <a href={appendAffiliateParam(itunesSong.trackViewUrl)} target="_blank" rel="noreferrer">
            <Image src={itunesSong.artworkUrl100} thumbnail className="mr-3" />
          </a>
          <Media.Body>
            <a
              href={appendAffiliateParam(itunesSong.collectionViewUrl)}
              target="_blank"
              rel="noreferrer"
              className="text-muted"
            >
              {itunesSong.collectionName} {itunesSong.trackNumber}
            </a>
            <h5>
              <a
                href={appendAffiliateParam(itunesSong.trackViewUrl)}
                target="_blank"
                rel="noreferrer"
                className="text-dark"
              >
                {itunesSong.trackName}
              </a>{' '}
              /{' '}
              <a
                href={appendAffiliateParam(itunesSong.artistViewUrl)}
                target="_blank"
                rel="noreferrer"
                className="text-dark"
              >
                {itunesSong.artistName}
              </a>
            </h5>
            <audio src={itunesSong.previewUrl} controls />
          </Media.Body>
        </Media>
      </Card.Body>
    </Card>
  );
};
