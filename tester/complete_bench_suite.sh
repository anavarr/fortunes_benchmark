# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

#Example for Red : '\033[0;31m'
#Example for NoColor : '\033[0m'

duration=5m
mydir=$(pwd)
do_stuff() {
    prefix="http://localhost:8080/fortunes"
    array=("quarkus-999" "quarkus-999-blocking" "quarkus-loom")
    # array=("quarkus-999" "quarkus-loom")
    array=("quarkus-999-blocking")
    ulimit -n 1000000;

    concurrencyLvl=$i

    for i in "${array[@]}"; do 
        echo "start $i"
        cd ../$i
        ./start_docker.sh &
        # ./start_applocal.sh &
        sleep 12
        echo "start warmup"
        ~/manual_installs/hey/hey -c 1000 -z 10s http://localhost:8080/fortunes
        echo "warmup done"
        (
            j=0
            cd $mydir
            rm $mydir/../latency_res/concurreny_lvl_$concurrencyLvl/$i.rss
            while true;
            do
            docker run --rm --privileged --pid=host justincormack/nsenter1 /bin/bash -c 'ps -e -o pid,rss,comm,args' | grep --color=auto --color=auto "java \-\-add\-opens java.base/java.lang" | awk '{$2=int($2/1024)"M";}{ print $2;}' |head -n 1 >> $mydir/../latency_res/concurreny_lvl_$concurrencyLvl/$i.rss
            j=$((j+1))
            sleep 10
            done
        ) &
        echo "started rss probe"
        mypid=$!
        echo "the pid is $mypid"
        /home/arnavarr/manual_installs/hyperfoil-0.19/bin/wrk2.sh -t2 -c$concurrencyLvl -R $concurrencyLvl -d $duration --timeout 20s --latency http://localhost:8080/fortunes > $mydir/../latency_res/$folder/$i.hgrm
        # /home/arnavarr/Documents/thesis/sources/wrk2/wrk -c$(($concurrencyLvl*2)) -R$concurrencyLvl -d$duration --timeout 20s --latency http://localhost:8080/fortunes > ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/$folder/$i.hgrm
        kill -9 $mypid
        ps > /dev/null
        echo "benched $i"
        mv /tmp/hyperfoil/run/0000 /tmp/hyperfoil/run/${folder}_${i}
        dockerid=$(docker ps |grep $i-test | awk '{print $1}' |head -n 1)
        docker stop ${dockerid}
        echo ""
        echo "sleeping to let it rest a bit..."
        sleep 60
    done
}





for i in {800..2200..100}
do
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo -e "\033[0;31m ============ Starting the tests for $i sql connections and $i workers =========== \033[0m"
    echo ""
    cd ..
    ./prepare_all.sh 1100 $i
    folder=concurreny_lvl_${i}
    cd latency_res
    [ ! -d $folder ] && mkdir $folder
    cd ../tester
    do_stuff
done

