package io.quarkus.benchmark.repository;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

import io.quarkus.benchmark.model.World;
import io.smallrye.common.annotation.RunOnVirtualThread;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.Tuple;

@ApplicationScoped
public class WorldRepository {

    @Inject
    PgClients clients;

    @RunOnVirtualThread
    public World find(int id) {
        var rowset = clients.getPool().preparedQuery("SELECT id, randomNumber FROM World WHERE id = $1")
                .execute(Tuple.of(id)).await().indefinitely();
        var row = rowset.iterator().next();
        return new World(row.getInteger(0), row.getInteger(1));
    }

    @RunOnVirtualThread
    public void update(World[] worlds) {
        Arrays.sort(worlds);
        List<Tuple> args = new ArrayList<>(worlds.length);
        for (World world : worlds) {
            args.add(Tuple.of(world.getId(), world.getRandomNumber()));
        }
        clients.getPool().preparedQuery("UPDATE World SET randomNumber = $2 WHERE id = $1")
                .executeBatch(args)
                .map(v -> null).await().indefinitely();
        return;
    }
}
