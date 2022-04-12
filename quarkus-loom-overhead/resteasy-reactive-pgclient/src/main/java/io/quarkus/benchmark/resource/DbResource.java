package io.quarkus.benchmark.resource;

import java.util.Arrays;
import java.util.List;
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
@Path("/")
@Blocking
public class DbResource {

    @Inject
    WorldRepository worldRepository;

    @GET
    @Path("db")
    @RunOnVirtualThread
    public Uni<World> db() {
        return randomWorld();
    }

    @GET
    @Path("queries")
    @RunOnVirtualThread
    public Uni<List<World>> queries(@QueryParam("queries") String queries) {
        var worlds = new Uni[parseQueryCount(queries)];
        var ret = new World[worlds.length];
        Arrays.setAll(worlds, i -> randomWorld().map(w -> ret[i] = w));

        return Uni.combine().all().unis(worlds)
                .combinedWith(v -> Arrays.asList(ret));
    }

    @GET
    @Path("updates")
    @RunOnVirtualThread
    public Uni<List<World>> updates(@QueryParam("queries") String queries) {
        var worlds = new Uni[parseQueryCount(queries)];
        var ret = new World[worlds.length];
        Arrays.setAll(worlds, i -> randomWorld().map(w -> {
            w.setRandomNumber(randomWorldNumber());
            ret[i] = w;
            return w;
        }));


        return Uni.combine().all().unis(worlds)
        .combinedWith(v -> null)
        .flatMap(v -> worldRepository.update(ret))
        .map(v -> Arrays.asList(ret));
    }

    private Uni<World> randomWorld() {
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