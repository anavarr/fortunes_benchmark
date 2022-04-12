package io.quarkus.benchmark.repository;

import io.vertx.mutiny.pgclient.PgPool;
import io.vertx.mutiny.sqlclient.SqlClient;

class PgClients {
    private static final int POOL_SIZE = 4;

    private ThreadLocal<SqlClient> sqlClient = new ThreadLocal<>();
    private ThreadLocal<PgPool> pool = new ThreadLocal<>();
    private PgClientFactory pgClientFactory;

	// for ArC
	public PgClients() {
	}

	public PgClients(PgClientFactory pgClientFactory) {
	    this.pgClientFactory = pgClientFactory;
    }

    SqlClient getClient() {
        return pgClientFactory.getSqlClient();
    }

    synchronized PgPool getPool() {
        return pgClientFactory.getSqlPool(POOL_SIZE);
    }
}