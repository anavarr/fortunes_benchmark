FROM quay.io/arnavarr/jdk19-loom
WORKDIR /quarkus-loom
ENV MODULE=resteasy-reactive-pgclient-full-synchronous

#COPY --from=maven /quarkus-loom/$MODULE/target//lib lib
COPY $MODULE/target/ /target

EXPOSE 8080
CMD ["java","--add-opens","java.base/java.lang=ALL-UNNAMED", "-server","-Xmx2048m", "-XX:+UseStringDeduplication", "-XX:+UseNUMA", "-XX:+UseParallelGC", "-Djava.lang.Integer.IntegerCache.high=10000","-Dvertx.disableHttpHeadersValidation=true", "-Dvertx.disableMetrics=true", "-Dvertx.disableH2c=true","-Dvertx.disableWebsockets=true", "-Dvertx.flashPolicyHandler=false", "-Dvertx.threadChecks=false","-Dvertx.disableContextTimings=true", "-Dvertx.disableTCCL=true", "-Dhibernate.allow_update_outside_transaction=true","-Djboss.threads.eqe.statistics=false", "-jar",  "/target/quarkus-app/quarkus-run.jar"]
