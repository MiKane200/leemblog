## LinkedHashMap的特点
LinkedHashMap通常提供的是遍历顺序符合插入顺序，它的实现是通过为条目（键值对）维护一个双向链表。注意，通过特定构造函数，我们可以创建反映访问顺序的实例，所谓的put、get、compute等，都算作“访问”。
这种行为适用于一些特定应用场景，例如，我们构建一个空间占用敏感的资源池，希望可以自动将最不常被访问的对象释放掉，这就可以利用LinkedHashMap提供的机制来实现，参考下面的示例：
```java
import java.util.LinkedHashMap;
import java.util.Map;  
public class LinkedHashMapSample {
    public static void main(String[] args) {
        LinkedHashMap<String, String> accessOrderedMap = new LinkedHashMap<>(16, 0.75F, true){
            @Override
            protected boolean removeEldestEntry(Map.Entry<String, String> eldest) { // 实现自定义删除策略，否则行为就和普遍Map没有区别
                return size() > 3;
            }
        };
        accessOrderedMap.put("Project1", "Valhalla");
        accessOrderedMap.put("Project2", "Panama");
        accessOrderedMap.put("Project3", "Loom");
        accessOrderedMap.forEach( (k,v) -> {
            System.out.println(k +":" + v);
        });
        // 模拟访问
        accessOrderedMap.get("Project2");
        accessOrderedMap.get("Project2");
        accessOrderedMap.get("Project3");
        System.out.println("Iterate over should be not affected:");
        accessOrderedMap.forEach( (k,v) -> {
            System.out.println(k +":" + v);
        });
        // 触发删除
        accessOrderedMap.put("Project4", "Mission Control");
        System.out.println("Oldest entry should be removed:");
        accessOrderedMap.forEach( (k,v) -> {// 遍历顺序不变
            System.out.println(k +":" + v);
        });
    }
}
```

## HashMap的负载因子
- 负载因子 * 容量 > 元素数量
- 所以，预先设置的容量需要满足，大于“预估元素数量/负载因子”，同时它是2的幂数，结论已经非常清晰了。

1. 而对于负载因子，建议：
    1. 如果没有特别需求，不要轻易进行更改，因为JDK自身的默认负载因子是非常符合通用场景的需求的。
    2. 如果确实需要调整，建议不要设置超过0.75的数值，因为会显著增加冲突，降低HashMap的性能。
    3. 如果使用太小的负载因子，按照上面的公式，预设容量值也进行调整，否则可能会导致更加频繁的扩容，增加无谓的开销，本身访问性能也会受影响。

## 那么，为什么HashMap要树化呢？
**本质上这是个安全问题。**
1. 因为在元素放置过程中，如果一个对象哈希冲突，都被放置到同一个桶里，则会形成一个链表，我们知道链表查询是线性的，会严重影响存取的性能。
2. 而在现实世界，构造哈希冲突的数据并不是非常复杂的事情，恶意代码就可以利用这些数据大量与服务器端交互，导致服务器端CPU大量占用，这就构成了哈希碰撞拒绝服务攻击，国内一线互联网公司就发生过类似攻击事件。


## Hashtable、HashMap、TreeMap心得
三者均实现了Map接口，存储的内容是基于key-value的键值对映射，一个映射不能有重复的键，一个键最多只能映射一个值。
1. 元素特性
HashTable中的key、value都不能为null；HashMap中的key、value可以为null，很显然只能有一个key为null的键值对，但是允许有多个值为null的键值对；TreeMap中当未实现 Comparator 接口时，key 不可以为null；当实现 Comparator 接口时，若未对null情况进行判断，则key不可以为null，反之亦然。
2. 顺序特性
HashTable、HashMap具有无序特性。TreeMap是利用红黑树来实现的（树中的每个节点的值，都会大于或等于它的左子树种的所有节点的值，并且小于或等于它的右子树中的所有节点的值），实现了SortMap接口，能够对保存的记录根据键进行排序。所以一般需要排序的情况下是选择TreeMap来进行，默认为升序排序方式（深度优先搜索），可自定义实现Comparator接口实现排序方式。
3. 初始化与增长方式
初始化时：HashTable在不指定容量的情况下的默认容量为11，且不要求底层数组的容量一定要为2的整数次幂；HashMap默认容量为16，且要求容量一定为2的整数次幂。
扩容时：Hashtable将容量变为原来的2倍加1；HashMap扩容将容量变为原来的2倍。
4. 线程安全性
HashTable其方法函数都是同步的（采用synchronized修饰），不会出现两个线程同时对数据进行操作的情况，因此保证了线程安全性。也正因为如此，在多线程运行环境下效率表现非常低下。因为当一个线程访问HashTable的同步方法时，其他线程也访问同步方法就会进入阻塞状态。比如当一个线程在添加数据时候，另外一个线程即使执行获取其他数据的操作也必须被阻塞，大大降低了程序的运行效率，在新版本中已被废弃，不推荐使用。
HashMap不支持线程的同步，即任一时刻可以有多个线程同时写HashMap;可能会导致数据的不一致。如果需要同步（1）可以用 Collections的synchronizedMap方法；（2）使用ConcurrentHashMap类，相较于HashTable锁住的是对象整体， ConcurrentHashMap基于lock实现锁分段技术。首先将Map存放的数据分成一段一段的存储方式，然后给每一段数据分配一把锁，当一个线程占用锁访问其中一个段的数据时，其他段的数据也能被其他线程访问。ConcurrentHashMap不仅保证了多线程运行环境下的数据访问安全性，而且性能上有长足的提升。
5. 一段话HashMap
HashMap基于哈希思想，实现对数据的读写。当我们将键值对传递给put()方法时，先是使用equals方法来判断是否有键相同的，然后就调用键对象的hashCode()方法来计算hashcode，通过这个hashcode来确定数组的索引位置，如果这个位置有值了（说明key不一样但hashcode一样）就要链表后加值，如果没值，就找到bucket位置，然后来储存值对象。当获取对象时，通过键对象的equals()方法找到正确的键值对，然后返回值对象。HashMap使用链表来解决碰撞问题，当发生碰撞了，对象将会储存在链表的下一个节点中。 HashMap在每个链表节点中储存键值对对象。当两个不同的键对象的hashcode相同时，它们会储存在同一个bucket位置的链表中，可通过键对象的equals()方法用来找到键值对。如果链表大小超过阈值（TREEIFY_THRESHOLD, 8），链表就会被改造为树形结构。

## HashMap.put大致过程
1. 首先调用hash方法，将key对象的hashCode计算出Node的hash, 根据hash计算出其在数组中的index，将键和值放入Entry中 
2. 如果没碰撞直接放到bucket里； 
3. 如果碰撞（index相同），就以链表的形式存放bucket中 
4. 如果碰撞导致链表的长度大于TREEIFY_THRESHOLD - 1，将链表的结构转换为红黑树。 
5. 如果key已经存在，替换old value 
6. 如果bucket存放的current capacity（当前容量）超过容量的load factor（0.75），就resize 