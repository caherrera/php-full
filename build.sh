#!/bin/bash

#docker build --squash -t carlositline/php-full:7.4.10-fpm-alpine 7.4/alpine/fpm
#docker build --squash -t carlositline/php-full:7.4.10-cli-alpine 7.4/alpine/cli

#tags="7.4.14 7.4 7"
#for o in alpine buster; do
#  for t in fpm cli; do
#      ot="carlositline/php-full:$t-$o"
#      docker build -t $ot 7.4/$o/$t || exit 1
#      for tag in $tags; do
#          docker tag $ot "carlositline/php-full:$tag-$t-$o" || exit 1
#          docker push "carlositline/php-full:$tag-$t-$o" || exit 1
#      done
#      docker push $ot || exit 1
#  done
#done
echo