package io.quarkus.benchmark.resource;

import java.io.StringWriter;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.github.mustachejava.DefaultMustacheFactory;
import com.github.mustachejava.Mustache;
import com.github.mustachejava.MustacheFactory;

import io.quarkus.benchmark.model.Fortune;
import io.quarkus.benchmark.repository.FortuneRepository;
import io.smallrye.common.annotation.Blocking;
import io.smallrye.common.annotation.RunOnVirtualThread;
import io.smallrye.mutiny.Uni;

@Path("/fortunes")
public class FortuneResource  {

    @Inject
    FortuneRepository repository;
    private Mustache template;
    private Comparator<Fortune> fortuneComparator;


    public FortuneResource() {
        MustacheFactory mf = new DefaultMustacheFactory();
        template = mf.compile("fortunes.mustache");
        fortuneComparator = Comparator.comparing(fortune -> fortune.getMessage());
    }



    @GET
    @Blocking
    @Produces(MediaType.APPLICATION_JSON)
    public List<Fortune> fortunes() {
//        System.out.println(Thread.currentThread());
        var fortunes = repository.findAll();
        fortunes.add(new Fortune(0, "Additional fortune added at request time."));
        fortunes.sort(fortuneComparator);
        return fortunes;
    }
}
