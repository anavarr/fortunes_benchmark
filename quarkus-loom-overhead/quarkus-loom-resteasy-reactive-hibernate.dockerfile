FROM maven:3.6.3-jdk-11-slim as maven
WORKDIR /quarkus-loom
ENV MODULE=resteasy-reactive-hibernate

COPY pom.xml pom.xml
COPY $MODULE/pom.xml $MODULE/pom.xml

RUN mkdir /root/.m2
COPY /quarkus-repo /root/.m2/repository/io/quarkus
#RUN mvn dependency:go-offline -q
# Uncomment to test pre-release quarkus
#RUN mkdir -p /root/.m2/repository/io
#COPY m2-quarkus /root/.m2/repository/io/quarkus

WORKDIR /quarkus-loom/$MODULE
WORKDIR /quarkus-loom

COPY $MODULE/src $MODULE/src

WORKDIR /quarkus-loom/$MODULE
RUN mvn package -q
WORKDIR /quarkus-loom

FROM jdk19-loom:latest
WORKDIR /quarkus-loom
ENV MODULE=resteasy-reactive-hibernate

#COPY --from=maven /quarkus-loom/$MODULE/target//lib lib
COPY --from=maven /quarkus-loom/$MODULE/target/ /target

EXPOSE 8080

CMD ["java","--add-opens","java.base/java.lang=ALL-UNNAMED", "-server", "-XX:-UseBiasedLocking", "-XX:+UseStringDeduplication", "-XX:+UseNUMA", "-XX:+UseParallelGC", "-Djava.lang.Integer.IntegerCache.high=10000", "-Dvertx.disableHttpHeadersValidation=true", "-Dvertx.disableMetrics=true", "-Dvertx.disableH2c=true", "-Dvertx.disableWebsockets=true", "-Dvertx.flashPolicyHandler=false", "-Dvertx.threadChecks=false", "-Dvertx.disableContextTimings=true", "-Dvertx.disableTCCL=true", "-Dhibernate.allow_update_outside_transaction=true", "-Djboss.threads.eqe.statistics=false", "-jar",  "/target/quarkus-app/quarkus-run.jar"]
