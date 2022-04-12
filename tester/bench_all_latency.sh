
prefix="http://localhost:8080/fortunes"
array=("quarkus-999" "quarkus-999-blocking" "quarkus-loom")
# array=("quarkus-999-blocking")
ulimit -n 1000000;


concurrencyLvl=$1
benchmarkDuration=$2

for i in "${array[@]}"; do   # The quotes are necessary here
    echo "start $i"
    cd ../$i
    ./start_docker.sh &
    sleep 12
    echo "start warmup"
    # ~/manual_installs/hey/hey -t 0 -c 1000 -z 10s http://localhost:8080/fortunes
    echo "warmup done"
    # (~/Documents/thesis/prog/java/CUSTOM_TECHEMP/tester/probe_rss.sh $i $3) &
    (
        j=0
        cd ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/tester/
        echo $1
        echo $2
        rm ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/concurreny_lvl_$1/$i.rss
        while true;
        do
        docker run -it --rm --privileged --pid=host justincormack/nsenter1 /bin/bash -c 'ps -e -o pid,rss,comm,args' | grep --color=auto --color=auto "java \-\-add\-opens java.base/java.lang" | awk '{$2=int($2/1024)"M";}{ print $2;}' |head -n 1 >> ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/concurreny_lvl_$1/$i.rss
        j=$((j+1))
        sleep 1
        done
    ) &
    echo "started rss probe"
    mypid=$!
    /home/arnavarr/manual_installs/hyperfoil-0.19/bin/wrk2.sh -c $1 -R $1 -d $2 --latency http://localhost:8080/fortunes > ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/$3/$i.hgrm
    kill -9 $mypid
    ps
    # ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/tester/get_rss.sh > ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/$3/$i.rss
    echo "benched $i"
    dockerid=$(docker ps |grep $i-test | awk '{print $1}' |head -n 1)
    docker stop $dockerid
    sleep 2
done