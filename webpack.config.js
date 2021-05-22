const glob = require('glob');
const path = require('path');
const webpack = require('webpack');
const WebpackAssetsManifest = require('webpack-assets-manifest');

const { NODE_ENV } = process.env;
const isProd = NODE_ENV === 'production';

const entry = {};
for (const p of glob.sync(path.resolve(__dirname, 'app/javascript/packs/*.{js,ts}'))) {
  entry[path.basename(p, path.extname(p))] = p;
}

module.exports = {
  entry: entry,
  mode: isProd ? 'production' : 'development',
  output: {
    path: path.resolve(__dirname, 'public/packs'),
    publicPath: '/packs/',
    filename: isProd ? '[name]-[contenthash].js' : '[name].js',
  },
  module: {
    rules: [
      {
        test: /\.(js|ts)x?$/,
        loader: 'ts-loader',
        options: {
          transpileOnly: true,
        },
      },
    ],
  },
  resolve: {
    extensions: ['.js', '.ts'],
  },
  optimization: {
    splitChunks: {
      chunks: 'initial',
      name: 'vendor',
    },
  },
  plugins: [
    new WebpackAssetsManifest({
      publicPath: true,
      output: 'manifest.json',
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    }),
  ],
  devtool: 'source-map',
};
