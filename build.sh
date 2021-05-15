#!/bin/bash
yarn clean
yarn build

rm ./public/live2d-widget/autoload.js
rm ./public/live2d-widget/waifu-tips.js
rm ./public/live2d-widget/waifu-tips.json

cp ./source/live2d-widget/autoload.js ./public/live2d-widget/
cp ./source/live2d-widget/waifu-tips.js ./public/live2d-widget/
cp ./source/live2d-widget/waifu-tips.json ./public/live2d-widget/