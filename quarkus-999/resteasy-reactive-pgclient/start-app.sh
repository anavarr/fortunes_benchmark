java -XX:+FlightRecorder -XX:+UseParallelGC -Xmx256m --add-opens java.base/java.lang=ALL-UNNAMED -Dquarkus.datasource.url=vertx-reactive:postgresql://localhost:5432/hello_world -Dquarkus.http.host=127.0.0.1 -Djava.lang.Integer.IntegerCache.high=10000 -Dvertx.disableHttpHeadersValidation=true -Dvertx.disableMetrics=true -Dvertx.disableH2c=true -Dvertx.disableWebsockets=true -Dvertx.flashPolicyHandler=false -Dvertx.threadChecks=false -Dvertx.disableContextTimings=true -Dvertx.disableTCCL=true -Dhibernate.allow_update_outside_transaction=true -Djboss.threads.eqe.statistics=false -jar target/quarkus-app/quarkus-run.jar
