#!/bin/bash

array=(de en es fr gr id it jp kr nl pl pt ru zh ro ar da)
for i in "${array[@]}"
do
  echo "Changing LANG to LANGUAGE for language $i"
  heroku config:set DMLANG=$i --app discover-meteor-$i
done