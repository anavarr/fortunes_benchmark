package io.quarkus.benchmark.repository;

import java.util.ArrayList;
import java.util.List;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

import io.quarkus.benchmark.model.Fortune;
import io.smallrye.common.annotation.Blocking;
import io.smallrye.common.annotation.RunOnVirtualThread;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.sqlclient.Row;

@ApplicationScoped
public class FortuneRepository {

    @Inject
    PgClients clients;

    public List<Fortune> findAll() {
        var rowset = clients.getPool().preparedQuery("SELECT * FROM Fortune" )
                .execute().await().indefinitely();
        List<Fortune> ret = new ArrayList<>(rowset.size()+1);
        for(Row r : rowset) {
            ret.add(new Fortune(r.getInteger("id"), r.getString("message")));
        }
        return ret;
    }
}
