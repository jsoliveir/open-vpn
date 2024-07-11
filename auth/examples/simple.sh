#!/bin/bash

if [[ $username == "admin" ]] && [[ $password == "admin" ]];
    then exit 0;
fi

exit 1
