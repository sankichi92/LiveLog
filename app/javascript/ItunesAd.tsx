import React, { useEffect, useState } from 'react';
import * as Sentry from '@sentry/browser';

type Props = {
  searchTerm: string;
};

type ItunesSearchResult = {
  results: {
    trackViewUrl: string;
  }[];
};

export const ItunesAd: React.FC<Props> = ({ searchTerm }: Props) => {
  const [itunesSearchResult, setItunesSearchResult] = useState<ItunesSearchResult | null>(null);

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

      const response = await fetch(itunesSearchURL.toString(), {
        mode: 'cors',
        redirect: 'manual',
      });

      if (response.ok) {
        const searchResult = await response.json();
        setItunesSearchResult(searchResult);
      } else if (response.status === 0) {
        // https://stackoverflow.com/questions/3825581/does-an-http-status-code-of-0-have-any-meaning
        Sentry.captureMessage('iTunes Search API request failed (status is 0)', { level: Sentry.Severity.Debug });
      } else if (response.redirected) {
        Sentry.captureMessage(`iTunes Search API returned unexpected redirect`, {
          level: Sentry.Severity.Debug,
          extra: {
            status: `${response.status} ${response.statusText}`,
            url: response.url,
            headers: response.headers,
          },
        });
      } else {
        throw new Error(`iTunes Search API request failed (${response.status} ${response.statusText})`);
      }
    })();
  }, [searchTerm]);

  if (itunesSearchResult === null || itunesSearchResult.results.length === 0) {
    return null;
  }

  // https://affiliate.itunes.apple.com/resources/documentation/basic_affiliate_link_guidelines_for_the_phg_network/
  // https://tools.applemediaservices.com/
  const affiliateEmbedSrc = new URL(itunesSearchResult.results[0].trackViewUrl);
  affiliateEmbedSrc.hostname = 'embed.music.apple.com';
  affiliateEmbedSrc.searchParams.append('app', 'music');
  affiliateEmbedSrc.searchParams.append('at', '1001lKQU');

  return (
    <div className="mb-3">
      <iframe
        src={affiliateEmbedSrc.toString()}
        height="150px"
        frameBorder="0"
        sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-top-navigation-by-user-activation"
        allow="autoplay *; encrypted-media *;"
        style={{
          width: '100%',
          overflow: 'hidden',
          borderRadius: '10px',
          background: 'transparent',
        }}
      ></iframe>
    </div>
  );
};
