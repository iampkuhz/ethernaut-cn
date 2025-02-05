# 脚本工具

```bash
# 将图片换成圆角
convert input.jpg \( +clone  -alpha extract -draw 'fill black polygon 0,0 0,10 10,0 fill white circle 10,10 10,0' \( +clone -flip \) -compose Multiply -composite \( +clone -flop \) -compose Multiply -composite \) -alpha off -compose CopyOpacity -composite tmp.png

# 创建带有空白边框和阴影的png图片
magick tmp.png \( +clone -background black -shadow 80x10+0+0 \) +swap -background none -layers merge -bordercolor none -border 100x0 abc.png
```