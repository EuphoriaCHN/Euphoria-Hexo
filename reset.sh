#!/bin/bash
hexo clean
hexo g
rm ./public/live2d-widget/waifu-tips.js
rm ./public/live2d-widget/waifu-tips.json
cp ./source/live2d-widget/waifu-tips.js ./public/live2d-widget/
cp ./source/live2d-widget/waifu-tips.json ./public/live2d-widget/
echo ALL WORKS OK! STATUS 200