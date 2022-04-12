package io.quarkus.benchmark.repository;

import io.vertx.mutiny.core.Vertx;
import io.vertx.mutiny.pgclient.PgPool;
import io.vertx.pgclient.PgConnectOptions;
import io.vertx.sqlclient.PoolOptions;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Produces;
import javax.inject.Inject;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ApplicationScoped
public class PgClientFactory {

    // vertx-reactive:postgresql://tfb-database:5432/hello_world
    private static final String PG_URI_MATCHER = "vertx-reactive:postgresql://([-a-zA-Z]+):([0-9]+)/(.*)";
	private static ConcurrentHashMap<String, PgPool> clients = new ConcurrentHashMap<>();
	private static ConcurrentHashMap<String, PgPool> pools = new ConcurrentHashMap<>();

    @ConfigProperty(name = "quarkus.datasource.url")
	String url;

	@ConfigProperty(name = "quarkus.datasource.username")
	String user;

	@ConfigProperty(name = "quarkus.datasource.password")
	String pass;

	@Inject
	Vertx vertx;

	@Produces
	@ApplicationScoped
	public PgClients pgClients() {
	    return new PgClients(this);
	}

	PgPool getSqlClient(){
		return getSqlConnection(clients, 1);
	}
	PgPool getSqlPool(int size){
		return getSqlConnection(pools, size);
	}

	PgPool getSqlConnection(ConcurrentHashMap<String, PgPool> map, int size){
		PgPool connection;
		try {
			Method m = Thread.class.getDeclaredMethod("currentCarrierThread");
			m.setAccessible(true);
			Thread carrier = (Thread) m.invoke(Thread.currentThread());
			connection = map.get(carrier.getName());
			if(connection == null){
				connection = sqlClient(size);
				map.put(carrier.getName(), connection);
			}
		} catch (IllegalAccessException | InvocationTargetException | NoSuchMethodException e) {
			e.printStackTrace();
			connection =null;
		}
		return connection;
	}

	PgPool sqlClient(int size) {
		PoolOptions options = new PoolOptions();
		PgConnectOptions connectOptions = new PgConnectOptions();
		Matcher matcher = Pattern.compile(PG_URI_MATCHER).matcher(url);
		matcher.matches();
		connectOptions.setDatabase(matcher.group(3));
		connectOptions.setHost(matcher.group(1));
		connectOptions.setPort(Integer.parseInt(matcher.group(2)));
		connectOptions.setUser(user);
		connectOptions.setPassword(pass);
		connectOptions.setCachePreparedStatements(true);
		options.setMaxSize(size);
		return PgPool.pool(vertx, connectOptions, options);
	}
}