#!/bin/bash

for file in $( find . -name '*.sh' | sort ); do 
    shellcheck "$file"
done
