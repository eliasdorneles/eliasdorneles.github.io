Title: Tips on Performance and Monitoring of Java Applications
Date: 2014-06-16 20:06
Author: Elias Dorneles

I cleaned up my desk this weekend and ended up finding some notes I wrote down
some time ago when I attended a course about monitoring JBoss application
servers. I haven't been doing much related to Java Web development lately, but
I'm going to try to make a quick summary here because: 1) then I can safely
throw away the paper with the notes, and 2) I think some of the tips can still
be useful in the context of many long running JVM processes.

### Memory and GC load

So, the most important thing to monitor in a long running JVM is arguably the
garbage collection stats. When some JVM is misbehaving, the first thing you
want to check is how much of the
[heap](https://en.wikipedia.org/wiki/Java_virtual_machine#Heap) is being used
and how often the full GC is being called.

One quick tip to reduce GC load is to set the initial heap size to the same
amount of the maximum heap size, namely, you should use the same value for the
`-Xms` and `-Xmx` JVM options. When you do this the JVM will allocate the
maximum space it will ever use, right from the the start. This way you avoid
memory reallocation for the heap and some GC calls, and can even sometimes
speedup the startup of an application, it is usually the first thing I do when
I install a Java desktop app like Eclipse or Intellij IDEA.

There are
[some](http://www.cubrid.org/blog/dev-platform/understanding-java-garbage-collection/)
[nice](http://www.cubrid.org/blog/dev-platform/how-to-monitor-java-garbage-collection/)
[articles](http://www.cubrid.org/blog/textyle/428187) about garbage collection
in Java available, it's a fairly big topic and I don't know much beyond the
basics to survive. You definitely want to know that full GC stops are bad and,
although you can't avoid them completely, you want to keep them to a minimum so
your application won't keep slogging.

Full GC stops happen when the area of memory reserved to objects that are "old"
(namely, objects that have been around for most of the time and therefore are
probably going to be around in the future) reaches its size limit. That means
that whatever application code was running will be stopped and only the GC will
execute for a moment, until some space is freed and your application code can
execute again ([or you'll be the misfortunate heir to
anOutOfMemoryError](https://plumbr.eu/blog/understanding-java-lang-outofmemoryerror)).

As it happens, tuning the garbage collection is very specific to the type of
application you're running. The JVM can use different garbage collection
algorithms, and you may want to twiddle with them a little bit to see what
works best. For your typical Java Web application, it's usually better to run
several machines with moderate memory in a cluster than run all in one big
machine with several GiB of memory due to how the GC works. However, your
mileage may vary, so your best bet is to measure and monitor what's happening
with the heap.    

### The number of threads vs backlog tradeoff

Now, in the case of Web applications, the second most important thing you want
to watch is the busy threads count. Usually, it represents the number of
requests being handled at a given moment. There is an useful tradeoff to be
aware of that has to do with how these things happen inside the Web container,
so bear with me for a little bit with the inaccurate description.

Whenever your application server (or whatever it is you're using to deploy your
Java Web app) gets a new request, it tries to respond as soon as possible
creating a new thread to handle it, right? Then, when the configured maximum
number of threads is reached, all the new requests are kept on a queue
(sometimes called backlog or acceptCount), waiting until one of the current
busy threads finishes so that the server can then get the next request from the
queue and use another thread to handle it.

Well, okay, it's not *reaaally* like that, I think what
really happens is that each new request always goes to the backlog queue and
there are some threads responsible for request processing that keep getting
work from the backlog, but I thought it would be a bit easier to explain that
way.

<center>
<img width="500" alt="I think my Tomcat can handle more work... Now, should I increase maxThreads or the backlog?"
src="https://3.bp.blogspot.com/-1Op2WBzfGno/U5928NTAtqI/AAAAAAAAAwQ/d1lxWxNcmHY/s1600/doubt-maxThreads_vs_backlog.jpg"/>
</center>

But here is the little secret: it's usually much easier for the operating
system to manage queues than attend threads. So, often enough it's better to
let the queue get big than to increase the maximum number of threads for your
system to handle. Threads are often competing for resources, increasing its
number may even hurt performance instead of improve it, specially when you have
a peak load.

Of course the best thing to do will depend on the application you are serving
and the load patterns in your server, so you need to measure it and experiment
for a bit to figure out what numbers work best for you.

So, if there is any way to wrap-up all this, it would be: measure it, measure
it, measure it! Different types of long-running JVM applications will have
different effects on your system, so it's important to have data to make good
decisions. Measuring the heap stats to see how the GC is doing and the number
of busy threads to see the patterns in request handling (in the case of Web
applications) is a good start.

Thanks for the review, José Ricardo and Valdir Stumm!

[Image credits (CCBY)](https://www.flickr.com/photos/24141546@N06/8097784516/in/photostream/)
