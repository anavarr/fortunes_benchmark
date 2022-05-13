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

do_stuff() {
    prefix="http://localhost:8080/fortunes"
    array=("quarkus-999" "quarkus-999-blocking" "quarkus-loom")
    # array=("quarkus-999" "quarkus-loom")
    # array=("quarkus-999-blocking")
    array=("quarkus-999")
    ulimit -n 1000000;

    concurrencyLvl=$i

    for name in "${array[@]}"; do 
        echo "start $name"
        cd ../$name
        ./start_docker.sh &
        for iter in {1..5..1}
        do
            # ./start_applocal.sh &
            sleep 12
            # the rss probe
            (
                rm ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/$name.rss
                while true;
                do
                docker run --rm --privileged --pid=host justincormack/nsenter1 /bin/bash -c 'ps -e -o pid,rss,comm,args' \
                | grep --color=auto --color=auto "java \-\-add\-opens java.base/java.lang" \
                | awk '{$2=int($2/1024)"M";}{ print $2;}' \
                |head -n 1 >> ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/$name.rss 
                sleep 10
                done
            ) &
            rss_probe_pid=$!
            echo "started rss probe"
            echo "the pid is $rss_probe_pid"
            # the #sql connections probe
            (
                rm ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/$name.cpu
                while true;
                do
                docker stats --no-stream | awk 'FNR==2{print $3}' >> \
                ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/$name.cpu
                sleep 10
                done
            ) &
            cpu_probe_pid=$!
            echo "started cpu probe"
            echo "the pid is $cpu_probe_pid"
            # the #sql connections probe
            (
                j=0
                rm ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/${name}_dbCound.dbc
                db_container=$(docker inspect -f '{{.State.Pid}}' quarkus_test)
                while true;
                do
                # sudo netstat netstat -na |grep 5432 |wc --lines >> \
                rm ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/${name}_${j}.dbc
                sudo nsenter -t $db_container -n ss -m -O |grep postgresql >> \
                ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/${name}_${j}.dbc
                cat ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/${name}_${j}.dbc | wc --lines >> \
                ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/${name}_dbCound.dbc

                j=$((j+1))
                sleep 10
                done
            ) &
            db_connections_pid=$!
            echo "started db connections probe"
            echo "the pid is $db_connections_pid"
            # /home/arnavarr/manual_installs/hyperfoil-0.19/bin/wrk2.sh -t2 -c$concurrencyLvl -R $concurrencyLvl -d $duration --timeout 20s --latency http://localhost:8080/fortunes > ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/$folder/$i.hgrm
            /home/arnavarr/manual_installs/hyperfoil-0.19/bin/wrk2.sh -t2 -c$(($concurrencyLvl*12/10)) -R$concurrencyLvl -d$duration --timeout 20s --latency http://localhost:8080/fortunes > ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/$name.hgrm
            kill -9 $rss_probe_pid
            kill -9 $cpu_probe_pid
            kill -9 $db_connections_pid
            ps > /dev/null
            echo "benched $name"
            rm -r ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/run_${name}
            mkdir ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/run_${name}
            mv /tmp/hyperfoil/run/0000/* ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac/$folder/run_${name}
            rm -r /tmp/hyperfoil/run/0000

            echo ""
            echo "sleeping to let it rest a bit..."
            sleep 65
        done
        dockerid=$(docker ps |grep $name-test | awk '{print $1}' |head -n 1)
        docker stop ${dockerid}
    done
}





for i in {2000..2100..200}
do
    for delay in {440..460..50}
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
    ~/manual_installs/pumba/pumba_linux_amd64 netem -d 50h --tc-image gaiadocker/iproute2 delay --time $delay --jitter 10 quarkus_test &
    pumba_pid=$!
    echo "started pumba : $pumba_pid"
    ./prepare_all.sh 500 $(($i*12/10))
    folder=concurreny_lvl_$(($i))_pumba_$(($delay))
    cd pumba_charac
    [ ! -d $folder ] && mkdir $folder
    do_stuff
    kill -9 $pumba_pid
    done
done

