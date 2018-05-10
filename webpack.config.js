const path = require('path');

const webpack = require('webpack');
const HtmlPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const VueLoaderPlugin = require('vue-loader/lib/plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

const ENV = process.env.NODE_ENV || 'local';
const SOURCE_FOLDER_NAME = '_src';

const MODULE_MAPPING = (function() {
    return {
        test: 'test-directory'
    }
})();

module.exports = {
    mode: ENV,
    entry: `./${SOURCE_FOLDER_NAME}`,
    output: {
        path: path.resolve(__dirname),
        publicPath: '/',
        filename: 'index.js'
    },
    resolve: {
        extensions: ['.js', '.vue', '.scss'],
        alias: {
            'vue$': 'vue/dist/vue.esm.js',
            'src': path.resolve(__dirname, SOURCE_FOLDER_NAME),
            'assets': path.resolve(__dirname, SOURCE_FOLDER_NAME, 'resources/assets'),
            'components': path.resolve(__dirname, SOURCE_FOLDER_NAME, 'components')
        }
    },
    module: {
        rules: [
            {
                test: /\.vue$/,
                loader: 'vue-loader'
            },
            {
                test: /\.js$/,
                loader: 'babel-loader',
                exclude: /node_modules/,
                include: [
                    path.resolve(__dirname, SOURCE_FOLDER_NAME),
                    require.resolve('bootstrap-vue')
                ]
            },
            {
                test: /\.s?css$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    'css-loader',
                    'sass-loader'
                ]
            },
            {
                test: /\.(png|jpg|gif|svg)$/,
                loader: 'file-loader',
                options: {
                    objectAssign: 'Object.assign'
                }
            }
        ]
    },
    devServer: {
        historyApiFallback: true,
        noInfo: true
    },
    performance: {
        hints: false
    },
    devtool: '#eval-source-map',
    plugins: [
        new webpack.DefinePlugin({
            MODULES: JSON.stringify(MODULE_MAPPING)
        }),
        new MiniCssExtractPlugin({
            filename: 'app.css'
        }),
        new VueLoaderPlugin(),
        new HtmlPlugin({
            hash: true,
            title: 'Vapor API Docs',
            template: path.resolve(__dirname, SOURCE_FOLDER_NAME, 'index.html')
        })
    ]
};

if (ENV === 'production') {
    module.exports.devtool = '#source-map';

    module.exports.optimization = {
        minimizer: [
            new UglifyJsPlugin({
                sourceMap: true
            }),
            new webpack.LoaderOptionsPlugin({
                minimize: true
            })
        ]
    };
}
