for fullFileName in ./assets/*.jpg; do
    fileName=$(basename $fullFileName .jpg)
    echo "converting ${fileName}"
    convert $fullFileName -resize 22x JPG:- | base64
    for width in 1920 1600 1366 1024 768 640; do
        convert $fullFileName -resize ${width}x -quality 85% "./assets/resized/${fileName}_${width}.jpg"
    done 
done