# FROM maven:3.6.3-jdk-11-slim as maven
# WORKDIR /quarkus-loom-overhead
# ENV MODULE=resteasy-reactive-pgclient-overhead

# COPY pom.xml pom.xml
# COPY $MODULE/pom.xml $MODULE/pom.xml

# RUN mkdir /root/.m2
# COPY /quarkus-repo /root/.m2/repository/io/quarkus
# #RUN mvn dependency:go-offline -q
# # Uncomment to test pre-release quarkus
# #RUN mkdir -p /root/.m2/repository/io
# #COPY m2-quarkus /root/.m2/repository/io/quarkus

# COPY $MODULE/src $MODULE/src

# WORKDIR /quarkus-loom-overhead/$MODULE
# RUN mvn package -q
# WORKDIR /quarkus-loom-overhead

FROM quay.io/arnavarr/jdk19-loom
WORKDIR /quarkus-loom-overhead
ENV MODULE=resteasy-reactive-pgclient-overhead

#COPY --from=maven /quarkus-loom/$MODULE/target//lib lib
COPY $MODULE/target/ /target

EXPOSE 8080

CMD ["java","--add-opens","java.base/java.lang=ALL-UNNAMED","-Xmx256m", "-server", "-XX:+UseStringDeduplication","-XX:+UseNUMA", "-XX:+UseParallelGC", "-Djava.lang.Integer.IntegerCache.high=10000","-Dvertx.disableHttpHeadersValidation=true", "-Dvertx.disableMetrics=true", "-Dvertx.disableH2c=true","-Dvertx.disableWebsockets=true", "-Dvertx.flashPolicyHandler=false", "-Dvertx.threadChecks=false","-Dvertx.disableContextTimings=true", "-Dvertx.disableTCCL=true", "-Dhibernate.allow_update_outside_transaction=true","-Djboss.threads.eqe.statistics=false", "-jar",  "/target/quarkus-app/quarkus-run.jar"]