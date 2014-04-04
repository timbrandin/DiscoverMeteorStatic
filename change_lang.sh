#!/bin/bash

array=(de en es fr gr id it jp kr nl pl pt ru zh ro ar da hr ms tr am uk th)
for i in "${array[@]}"
do
  echo "Setting DMLANG for language $i"
  heroku config:set DMLANG=$i --app discover-meteor-$i
done