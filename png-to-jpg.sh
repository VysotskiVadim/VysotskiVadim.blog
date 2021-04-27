for fullFileName in ./assets/*.png; do
    fileName=$(basename $fullFileName .png)
    echo "converting ${fileName} to jpg"
    convert $fullFileName "assets/${fileName}.jpg"
    rm $fullFileName
done