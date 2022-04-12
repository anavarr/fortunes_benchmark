package io.quarkus.benchmark.resource;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadLocalRandom;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

import io.quarkus.benchmark.model.World;
import io.quarkus.benchmark.repository.WorldRepository;
import io.smallrye.common.annotation.Blocking;
import io.smallrye.common.annotation.NonBlocking;
import io.smallrye.common.annotation.RunOnVirtualThread;
import io.smallrye.mutiny.Uni;

@Produces(MediaType.APPLICATION_JSON)
@Blocking
@Path("/")
public class DbResource {

    @Inject
    WorldRepository worldRepository;

    @GET
    @Path("db")
    @RunOnVirtualThread
    public World db() {
        return randomWorld();
    }

    @GET
    @Path("queries")
    @RunOnVirtualThread
    public List<World> queries(@QueryParam("queries") String queries) {
        World[] ret = new World[parseQueryCount(queries)];
        for(int i = 0; i< ret.length; i++){
            ret[i] = randomWorld();
        }
        return Arrays.asList(ret);
    }

    @GET
    @Path("updates")
    @RunOnVirtualThread
    public List<World> updates(@QueryParam("queries") String queries) {
        var worlds = new World[parseQueryCount(queries)];
        var ret = new World[worlds.length];

        for(int i = 0; i< ret.length; i++){
            var w = randomWorld();
            w.setRandomNumber(randomWorldNumber());
            ret[i] = w;
        }
        worldRepository.update(ret);
        return Arrays.asList(ret);
    }

    private World randomWorld() {
        return worldRepository.find(randomWorldNumber());
    }

    private int randomWorldNumber() {
        return 1 + ThreadLocalRandom.current().nextInt(10000);
    }

    private int parseQueryCount(String textValue) {
        if (textValue == null) {
            return 1;
        }
        int parsedValue;
        try {
            parsedValue = Integer.parseInt(textValue);
        } catch (NumberFormatException e) {
            return 1;
        }
        return Math.min(500, Math.max(1, parsedValue));
    }
}