#!/bin/bash
kolzip="%m%d%Y"
pass=$(date +"$kolzip")

filess=$(ls | grep -E "Kelinci_|Kucing_")
files=$(find -name "*_*" -type d)
# echo $files
zip -P $pass -mr Koleksi.zip $filess



# find -name "*_*" -type d | zip -P $pass -r Koleksi.zip