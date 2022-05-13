array=("quarkus" "quarkus-loom" "quarkus-999" "quarkus-999-blocking")

cd quarkus-loom
cd resteasy-reactive-pgclient-full-synchronous
sed -i -e '/quarkus\.thread-pool\.max-threads=/ s/=.*/='$1'/' src/main/resources/application.properties
sed -i -e '/quarkus\.sqlsize=/ s/=.*/='$2'/' src/main/resources/application.properties
mvn clean package -DskipTests 
cd ..
./build_docker.sh


cd ..
cd quarkus-999
cd resteasy-reactive-pgclient
sed -i -e '/quarkus\.thread-pool\.max-threads=/ s/=.*/='$1'/' src/main/resources/application.properties
sed -i -e '/quarkus\.sqlsize=/ s/=.*/='$2'/' src/main/resources/application.properties
mvn clean package -DskipTests 
cd ..
./build_docker.sh


cd ..
cd quarkus-999-blocking
cd resteasy-reactive-pgclient
sed -i -e '/quarkus\.thread-pool\.max-threads=/ s/=.*/='$1'/' src/main/resources/application.properties
sed -i -e '/quarkus\.sqlsize=/ s/=.*/='$2'/' src/main/resources/application.properties
mvn clean package -DskipTests 
cd ..
./build_docker.sh
