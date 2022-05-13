package io.quarkus.benchmark.repository;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Produces;
import javax.inject.Inject;

import io.vertx.mutiny.sqlclient.SqlClient;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import io.vertx.mutiny.core.Vertx;
import io.vertx.mutiny.pgclient.PgPool;
import io.vertx.pgclient.PgConnectOptions;
import io.vertx.sqlclient.PoolOptions;

@ApplicationScoped
public class PgClientFactory {

	// vertx-reactive:postgresql://tfb-database:5432/hello_world
	private static final String PG_URI_MATCHER = "vertx-reactive:postgresql://(.+):([0-9]+)/(.*)";
//	private static final String PG_URI_MATCHER = "(.+):([0-9]+)/(.*)";

	@ConfigProperty(name = "quarkus.datasource.url")
	String url;

	@ConfigProperty(name = "quarkus.datasource.username")
	String user;

	@ConfigProperty(name = "quarkus.datasource.password")
	String pass;

	@ConfigProperty(name = "quarkus.sqlsize")
	String sqlPoolSize;

	@ConfigProperty(name = "quarkus.thread-pool.max-threads")
	String threadMax;

	@Inject
	Vertx vertx;

	@Produces
	@ApplicationScoped
	public PgClients pgClients() {
		return new PgClients(this);
	}

	PgPool sqlClient(int size) {
		System.out.println("the size is  : "+sqlPoolSize);
		System.out.println("the number of threads is : "+threadMax);
		PoolOptions options = new PoolOptions();
		PgConnectOptions connectOptions = new PgConnectOptions();
		Matcher matcher = Pattern.compile(PG_URI_MATCHER).matcher(url);
		matcher.matches();
		connectOptions.setHost(matcher.group(1));
		connectOptions.setPort(Integer.parseInt(matcher.group(2)));
		connectOptions.setDatabase(matcher.group(3));
		connectOptions.setUser(user);
		connectOptions.setPassword(pass);
		connectOptions.setCachePreparedStatements(true);
		options.setMaxSize(Integer.parseInt(sqlPoolSize));
		return PgPool.pool(vertx, connectOptions, options);
	}
}