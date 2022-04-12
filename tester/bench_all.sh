
prefix="http://localhost:8080/fortunes"
array=("quarkus-999" "quarkus-loom")
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
    ~/manual_installs/hey/hey -t 0 -c 1000 -z 10s http://localhost:8080/fortunes
    echo "warmup done"
    ~/manual_installs/hey/hey -t 0 -c $concurrencyLvl -z $2 -o csv http://localhost:8080/fortunes > ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/tester/$3/$i.csv
    ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/tester/get_rss.sh
    ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/tester/get_rss.sh > ~/Documents/thesis/prog/java/CUSTOM_TECHEMP/tester/$3/$i.rss
    echo "benched $i"
    dockerid=$(docker ps |grep $i-test | awk '{print $1}' |head -n 1)
    docker stop $dockerid
    sleep 2
done