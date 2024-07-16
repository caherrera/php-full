#!/bin/bash

docker_prefix="docker buildx build --platform linux/amd64,linux/arm64,linux/arm64/v8,linux/arm/v7,linux/arm/v6,linux/386 --push "

for df in `find . -name Dockerfile| sort`; do  
    d=$(dirname $df)
    tag=$(echo $df | cut -d'/' -f2)
    os=$(echo $df | cut -d'/' -f3)
    svc=$(echo $df | cut -d'/' -f4)
    t1="carlositline/php-full:$tag-$svc-$os"
    t2="carlositline/php-full:$tag-$os"
    echo $docker_prefix -t $t1 -t $t2 $d
done
echo