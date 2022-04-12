package io.quarkus.benchmark.repository;

import io.vertx.mutiny.pgclient.PgPool;
import io.vertx.mutiny.sqlclient.SqlClient;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.util.concurrent.locks.ReentrantLock;

class PgClients {
    private static final int POOL_SIZE = 280;

    private PgClientFactory pgClientFactory;
    private SqlClient client;
    private PgPool pool;
    private final ReentrantLock lock = new ReentrantLock();
    // for ArC
    public PgClients() {
    }

    public PgClients(PgClientFactory pgClientFactory) {
        this.pgClientFactory = pgClientFactory;
    }

    SqlClient getClient() {
        lock.lock();
        if(client == null){
            client = pgClientFactory.sqlClient(1);
        }
        return client;
    }
    PgPool getPool() {
        lock.lock();
        if(pool == null){
            pool = pgClientFactory.sqlClient(POOL_SIZE);
        }
        lock.unlock();
        return pool;
    }
}