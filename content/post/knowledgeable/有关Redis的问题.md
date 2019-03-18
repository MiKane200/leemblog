## Redis有哪几种数据淘汰策略？
当前版本,Redis 3.0 支持的策略包括:
1. noeviction: 不删除策略, 达到最大内存限制时, 如果需要更多内存, 直接返回错误信息。 大多数写命令都会导致占用更多的内存(有极少数会例外, 如 DEL )。
2. allkeys-lru: 所有key通用; 优先删除最近最少使用(less recently used ,LRU) 的 key。
3. volatile-lru: 只限于设置了 expire 的部分; 优先删除最近最少使用(less recently used ,LRU) 的 key。
4. allkeys-random: 所有key通用; 随机删除一部分 key。
5. volatile-random: 只限于设置了 expire 的部分; 随机删除一部分 key。
6. volatile-ttl: 只限于设置了 expire 的部分; 优先删除剩余时间(time to live,TTL) 短的key。

* 如果没有设置 expire 的key, 不满足先决条件(prerequisites); 那么 volatile-lru, volatile-random 和 volatile-ttl 策略的行为, 和 noeviction(不删除) 基本上一致。您需要根据系统的特征, 来选择合适的驱逐策略。 当然, 在运行过程中也可以通过命令动态设置驱逐策略, 并通过 INFO 命令监控缓存的 miss 和 hit, 来进行调优。

#### 一般来说:
1. 如果分为热数据与冷数据, 推荐使用 allkeys-lru 策略。 也就是, 其中一部分key经常被读写. 如果不确定具体的业务特征, 那么allkeys-lru 是一个很好的选择。
2. 如果需要循环读写所有的key, 或者各个key的访问频率差不多, 可以使用 allkeys-random 策略, 即读写所有元素的概率差不多。
假如要让 Redis 根据 TTL 来筛选需要删除的key, 请使用 volatile-ttl 策略。
3. volatile-lru 和 volatile-random 策略主要应用场景是: 既有缓存,又有持久key的实例中。 一般来说, 像这类场景, 应该使用两个单独的 Redis 实例。

* 值得一提的是, 设置 expire 会消耗额外的内存, 所以使用 allkeys-lru 策略, 可以更高效地利用内存, 因为这样就可以不再设置过期时间了。

## String类型
1. string 是 redis 最基本的类型，你可以理解成与 Memcached 一模一样的类型，一个 key 对应一个 value。
2. string 类型是二进制安全的。意思是 redis 的 string 可以包含任何数据。比如jpg图片或者序列化的对象。
3. string 类型是 Redis 最基本的数据类型，string 类型的值最大能存储 512MB。

## Redis集群方案应该怎么做？都有哪些方案？
1. codis。目前用的最多的集群方案，基本和twemproxy一致的效果，但它支持在 节点数量改变情况下，旧节点数据可恢复到新hash节点。
2. redis cluster3.0自带的集群，特点在于他的分布式算法不是一致性hash，而是hash槽的概念，以及自身支持节点设置从节点。具体看官方文档介绍。
3. 在业务代码层实现，起几个毫无关联的redis实例，在代码层，对key 进行hash计算，然后去对应的redis实例操作数据。 这种方式对hash层代码要求比较高，考虑部分包括，节点失效后的替代算法方案，数据震荡后的自动脚本恢复，实例的监控，等等。

#### Redis集群方案什么情况下会导致整个集群不可用？
有A，B，C三个节点的集群,在没有复制模型的情况下,如果节点B失败了，那么整个集群就会以为缺少5501-11000这个范围的槽而不可用。

#### MySQL里有2000w数据，redis中只存20w的数据，如何保证redis中的数据都是热点数据？
redis内存数据集大小上升到一定大小的时候，就会施行数据淘汰策略。

## Redis有哪些适合的场景？
1. 会话缓存（Session Cache）最常用的一种使用Redis的情景是会话缓存（session cache）。用Redis缓存会话比其他存储（如Memcached）的优势在于：Redis提供持久化。
2. 全页缓存（FPC）除基本的会话token之外，Redis还提供很简便的FPC平台。回到一致性问题，即使重启了Redis实例，因为有磁盘的持久化，用户也不会看到页面加载速度的下降。
3. 队列Reids在内存存储引擎领域的一大优点是提供 list 和 set 操作，这使得Redis能作为一个很好的消息队列平台来使用。Redis作为队列使用的操作，就类似于本地程序语言（如Python）对 list 的 push/pop 操作。
4. 排行榜/计数器Redis在内存中对数字进行递增或递减的操作实现的非常好。集合（Set）和有序集合（Sorted Set）也使得我们在执行这些操作的时候变的非常简单，Redis只是正好提供了这两种数据结构。所以，我们要从排序集合中获取到排名最靠前的10个用户–我们称之为“user_scores”，我们只需要像下面一样执行即可：当然，这是假定你是根据你用户的分数做递增的排序。如果你想返回用户及用户的分数，你需要这样执行：ZRANGE user_scores 0 10 WITHSCORES
5. 发布/订阅最后（但肯定不是最不重要的）是Redis的发布/订阅功能。发布/订阅的使用场景确实非常多。我已看见人们在社交网络连接中使用，还可作为基于发布/订阅的脚本触发器，甚至用Redis的发布/订阅功能来建立聊天系统！

#### Redis支持的Java客户端都有哪些？官方推荐用哪个？
Redisson、Jedis、lettuce等等，官方推荐使用Redisson。

#### Redis和Redisson有什么关系？
Redisson是一个高级的分布式协调Redis客服端，能帮助用户在分布式环境中轻松实现一些Java的对象 (Bloom filter, BitSet, Set, SetMultimap, ScoredSortedSet, SortedSet, Map, ConcurrentMap, List, ListMultimap, Queue, BlockingQueue, Deque, BlockingDeque, Semaphore, Lock, ReadWriteLock, AtomicLong, CountDownLatch, Publish / Subscribe, HyperLogLog)。

## 说说Redis哈希槽的概念？
Redis集群没有使用一致性hash,而是引入了哈希槽的概念，Redis集群有16384个哈希槽，每个key通过CRC16校验后对16384取模来决定放置哪个槽，集群的每个节点负责一部分hash槽。其中CRC是（Cyclic Redundancy Check）循环冗余检验，是基于数据计算一组效验码，用于核对数据传输过程中是否被更改或传输错误。

## Redis主从复制
在一台节点上配置文件中定义自己是谁的从节点，并且启用主节点密码认证即可。
下面使用3台主机配置一主两从的结构，redis使用一主多从的结构时还可以实现像mysql MHA那样的复制集群，当master节点宕机后，可以在两个slave节点中根据优先级选举新的master。因此这里使用3个节点，这部分内容会在后面单独说道。
#### 复制的两种方式
新的从节点或某较长时间未能与主节点进行同步的从节点重新与主节点通信，需要做“full synchronization”，此时其同步方式有两种方式：
1. Disk-backend：主节点基于内存创建快照文件于磁盘中，而后将其发送给从节点；从节点收到快照进行恢复，快照恢复完后接着快照的那一刻随后内容进行复制，主节点每写一行，并直接将语句发送给从节点（跨网络复制适合）
2. Diskless：主节占新创建快照后直接通过网络套接字文件发送给从节点；为了实现并行复制，通常需要在复制启动前延迟一个时间段；（占用网络带宽）

## Redis集群会有写操作丢失吗？为什么？
#### Redis集群可能丢失写的第一个原因是因为它用异步复制。
1. 写可能是这样发生的：
    1. 客户端写到master B
    2. master B回复客户端OK
    3. master B将这个写操作广播给它的slaves B1、B2、B3
* 正如你看到的那样，B没有等到B1、B2、B3确认就回复客户端了，也就是说，B在回复客户端之前没有等待B1、B2、B3的确认，这对应Redis来说是一个潜在的风险。所以，如果客户端写了一些东西，B也确认了这个写操作，但是在它将这个写操作发给它的slaves之前它宕机了，随后其中一个slave（没有收到这个写命令）可能被提升为新的master，于是这个写操作就永远丢失了。

#### 第二个原因即Redis集群，在一个网络分区中，客户端与少数实例(包括至少一个主机)隔离。
简单的来说就是，本来三主三从在一个网络分区中，突然网络分区发生，于是一边是A、C、A1、B1、C1，另一边是B和Z1，这时候Z1往B中写数据，于此同时另一边（即A、C、A1、B1、C1）认为B已经挂了，于是将B1提升为master，当分区回复的时候，由于B1变成了master，所以B就成了slave，于是B就要丢弃它自己原有的数据而从B1那里同步数据，于是乎先去Z1写到B的数据就丢失了。

## Redis中的管道有什么用？
一次请求/响应服务器能实现处理新的请求即使旧的请求还未被响应。这样就可以将多个命令发送到服务器，而不用等待回复，最后在一个步骤中读取该答复。这就是管道（pipelining），是一种几十年来广泛使用的技术。例如许多POP3协议已经实现支持这个功能，大大加快了从服务器下载新邮件的过程。

## 怎么理解Redis事务
1. 事务是一个单独的隔离操作：事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中，不会被其他客户端发送来的命令请求所打断。
2. 事务是一个原子操作：事务中的命令要么全部被执行，要么全部都不执行。
3. 同时，redis使用AOF(append-only file)，使用一个额外的write操作将事务写入磁盘。如果发生宕机，进程奔溃等情况，可以使用redis-check-aof tool 修复append-only file，使服务正常启动，并恢复部分操作。
4. 单个 Redis 命令的执行是原子性的，但 Redis 没有在事务上增加任何维持原子性的机制，所以 Redis 事务的执行并不是原子性的。事务可以理解为一个打包的批量执行脚本，但批量指令并非原子化的操作，中间某条指令的失败不会导致前面已做指令的回滚，也不会造成后续的指令不做。

## Redis如何做内存优化？
尽可能使用散列表（hashes），散列表（是说散列表里面存储的数少）使用的内存非常小，所以你应该尽可能的将你的数据模型抽象到一个散列表里面。比如你的web系统中有一个用户对象，不要为这个用户的名称，姓氏，邮箱，密码设置单独的key,而是应该把这个用户的所有信息存储到一张散列表里面。

## redis分布式锁
#### 可靠性
首先，为了确保分布式锁可用，我们至少要确保锁的实现同时满足以下四个条件：
1. 互斥性。在任意时刻，只有一个客户端能持有锁。
2. 不会发生死锁。即使有一个客户端在持有锁的期间崩溃而没有主动解锁，也能保证后续其他客户端能加锁。
3. 具有容错性。只要大部分的Redis节点正常运行，客户端就可以加锁和解锁。
4. 解铃还须系铃人。加锁和解锁必须是同一个客户端，客户端自己不能把别人加的锁给解了。

加锁代码
```java
public class RedisTool {

    private static final String LOCK_SUCCESS = "OK";
    private static final String SET_IF_NOT_EXIST = "NX";
    private static final String SET_WITH_EXPIRE_TIME = "PX";

    /**
     * 尝试获取分布式锁
     * @param jedis Redis客户端
     * @param lockKey 锁
     * @param requestId 请求标识
     * @param expireTime 超期时间
     * @return 是否获取成功
     */
    public static boolean tryGetDistributedLock(Jedis jedis, String lockKey, String requestId, int expireTime) {

        String result = jedis.set(lockKey, requestId, SET_IF_NOT_EXIST, SET_WITH_EXPIRE_TIME, expireTime);

        if (LOCK_SUCCESS.equals(result)) {
            return true;
        }
        return false;

    }

}
```

可以看到，我们加锁就一行代码：jedis.set(String key, String value, String nxxx, String expx, int time)，这个set()方法一共有五个形参：
1. 第一个为key，我们使用key来当锁，因为key是唯一的。
2. 第二个为value，我们传的是requestId，很多童鞋可能不明白，有key作为锁不就够了吗，为什么还要用到value？原因就是我们在上面讲到可靠性时，分布式锁要满足第四个条件解铃还须系铃人，通过给value赋值为requestId，我们就知道这把锁是哪个请求加的了，在解锁的时候就可以有依据。requestId可以使用UUID.randomUUID().toString()方法生成。
3. 第三个为nxxx，这个参数我们填的是NX，意思是SET IF NOT EXIST，即当key不存在时，我们进行set操作；若key已经存在，则不做任何操作；
4. 第四个为expx，这个参数我们传的是PX，意思是我们要给这个key加一个过期的设置，具体时间由第五个参数决定。
5. 第五个为time，与第四个参数相呼应，代表key的过期时间。

* 总的来说，执行上面的set()方法就只会导致两种结果：1. 当前没有锁（key不存在），那么就进行加锁操作，并对锁设置个有效期，同时value表示加锁的客户端。2. 已有锁存在，不做任何操作。

* 我们的加锁代码满足我们可靠性里描述的三个条件。首先，set()加入了NX参数，可以保证如果已有key存在，则函数不会调用成功，也就是只有一个客户端能持有锁，满足互斥性。其次，由于我们对锁设置了过期时间，即使锁的持有者后续发生崩溃而没有解锁，锁也会因为到了过期时间而自动解锁（即key被删除），不会发生死锁。最后，因为我们将value赋值为requestId，代表加锁的客户端请求标识，那么在客户端在解锁的时候就可以进行校验是否是同一个客户端。由于我们只考虑Redis单机部署的场景，所以容错性我们暂不考虑。

#### 

## 什么是缓存击穿?
比如说如果有些人来访问，比如黑客，他想攻击你的系统的时候，他故意在同一时间内，给你制造很多不存在的值，如果在访问这些不存在的值的时候，发现缓存里面没有，那会把这些请求都会转发到数据库，那这样数据库压力就会变大，完全有可能承受不住导致数据库系统的崩溃；这样就是缓存击穿;

#### 解决击穿
1. 方案一：可以把不存在的key也设置缓存，并设置过期时间；
解决思路，尽量的把请求拦截到，不让它去访问数据库，那我们怎么去拦截呢，比如说，当拿一个不存在key访问程序的时候，如果查询数据库，不存在对应的值，那我们也会给不存在的这个key 存入到缓存里面，并且可以设置缓存失效时间；比如说可以把对应的key设置为null值存入到缓存里面，如果下次有相同的key来访问的时候，在缓存失效之前，都是直接从缓存里面取；这样就会把不必要的请求拦截下来；
* 如果假如后面业务需求的增加，这key在数据库里面已存在，那么缓存失效之后，就可以利用这key，去加载数据；

2. 方案二：使用redis或者zookeeper提供的互斥锁也可以解决缓存击穿
这种方案是通过异步方式 去获取缓存过程中，其他key 处于等待现象，必须等待第一个构建完缓存之后，释放锁，其他人才能通过该key才能访问数据;如下图所示
* 第一个key1 在查询db，获取数据 到放入缓存过程中，都有把锁 先锁住，其他人就必须等待，等待缓存设置成功，才去释放锁，那其他人就直接从缓存里面取数据；不会造成数据库的读写性能的缺陷;