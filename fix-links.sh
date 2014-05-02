#!/bin/sh

sed -e 's/_index\.html/index\.html/g' -i $(grep _index.html * -rl)
