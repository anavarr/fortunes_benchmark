prefix="http://localhost:8080/fortunes"

array=("quarkus" "quarkus-999" "quarkus-999-blocking" "quarkus-loom")
ulimit -n 1000000;



for i in "${array[@]}"; do   # The quotes are necessary here
    cd ../$i
    ./start_docker.sh &
    sleep 15
    echo "test $i"
    curl http://localhost:8080/fortunes
    echo "tested $i"
    dockerid=$(docker ps |grep $i-test | awk '{print $1}' |head -n 1)
    docker stop $dockerid
    sleep 5
done
