const glob = require('glob');
const path = require('path');
const TsconfigPathsPlugin = require('tsconfig-paths-webpack-plugin');
const webpack = require('webpack');
const WebpackAssetsManifest = require('webpack-assets-manifest');

const { NODE_ENV, USE_WEBPACK_DEV_SERVER } = process.env;
const isProd = NODE_ENV === 'production';

const entry = {};
for (const p of glob.sync(path.resolve(__dirname, 'app/javascript/packs/*.{js,ts,jsx,tsx}'))) {
  entry[path.basename(p, path.extname(p))] = p;
}

module.exports = {
  entry: entry,
  mode: isProd ? 'production' : 'development',
  output: {
    path: path.resolve(__dirname, 'public/packs'),
    publicPath: USE_WEBPACK_DEV_SERVER ? '//localhost:3035/packs/' : '/packs/',
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
    extensions: ['.js', '.ts', '.jsx', '.tsx'],
    plugins: [new TsconfigPathsPlugin()],
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
      writeToDisk: true,
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    }),
  ],
  devServer: {
    port: 3035,
  },
  devtool: 'source-map',
};
