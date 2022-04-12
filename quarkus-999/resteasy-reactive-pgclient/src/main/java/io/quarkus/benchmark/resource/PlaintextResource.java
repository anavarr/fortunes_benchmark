package io.quarkus.benchmark.resource;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import io.smallrye.common.annotation.NonBlocking;
import io.vertx.core.buffer.Buffer;

@Path("/plaintext")
public class PlaintextResource {
    private static final String HELLO_WORLD = "Hello, world!";
    private static final Buffer HELLO_WORLD_BUFFER = Buffer.buffer(HELLO_WORLD, "UTF-8");

    @Produces(MediaType.TEXT_PLAIN)
    @GET
    @NonBlocking
    public Buffer plaintext() {
        return HELLO_WORLD_BUFFER;
    }
}
