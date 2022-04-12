i=0
cd ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/tester/
echo $1
echo $2
rm ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/concurreny_lvl_$2/$1.rss
while true;
do
docker run --rm --privileged --pid=host justincormack/nsenter1 /bin/bash -c 'ps -e -o pid,rss,comm,args' | grep --color=auto --color=auto "java \-\-add\-opens java.base/java.lang" | awk '{$2=int($2/1024)"M";}{ print $2;}' |head -n 1 >> ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/concurreny_lvl_$2/$1.rss
i=$((i+1))
sleep 1
done