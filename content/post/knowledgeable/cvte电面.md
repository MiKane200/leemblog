## 丰富了面试过程中的答案
1. 在之前公司里面学了什么。 
    * 答：git，spring boot，spring cloud，docker，设计模式，DDD领域驱动模型，数据库，k8s。
2. 追问spring boot实现了什么
    * 答：通过组合元注解来实现对spring和spring mvc的繁琐配置。
3. 你说到了数据库，你比较熟悉哪个=>mysql，问数据库引擎你最常用的有哪两个=>innodb,mylsam，问他们有什么区别？
    * 答： mylsam是5.7以前默认的数据库引擎（非事务安全表），5.7以后默认引擎是Innodb（事务安全表）。这里如果答上来可能继续深入问：innodb是如何实现事务安全的？ 答： 
    1. mysql表中的基本数据类型有哪些？ char,varchar,int,BigInt,float,double,long,date,txt。
        1. 追问：char和varchar有什么区别，char固定长度，当值没有达到指定长度使用空格填充，但当检索到时，删除尾部空格，定长使得char查询效率较高。varchar除了保存字符还要在其后加上一个字节记录长度，如果列长度大小超过255则使用两个字节。所以综上：如果着重空间上考虑用varchar，时间效率上用char。 
    2. 追问innodb的索引的种类有哪些？
        * 答 三大类：B+索引（给定键值查找特定行所在的那一页，将页取出到内存，在内存中查找那行数据），全文索引，哈希索引（自适应的索引，不能人为干预，使用链表解决冲突）
            1. 对于B+索引有聚集索引
                1. Innodb是索引组织表，即表中的数据按照主键的顺序存放（innodb中的表必须要有主键如果没有设置会默认找一个可以唯一标示数据的列作为主键，如果不存在这样的列，则创建一个隐含字段作为主键，这个字段长度6字节，类型长整型）。聚集索引就是按照每张表构造一颗B+树，其叶子节点存放行记录数据!!!，称为数据页。
                2. 所以一张表只能有一个聚集索引。由于定义了数据的逻辑顺序，因此聚集索引能根据范围值进行查询，大多数情况下，查询优化器倾向于采用聚集索引查询。 
                3. 除此之外聚集索引的数据页通过双向链表进行链接，因此聚集索引是逻辑连续而不是物理连续。
            2. 和辅助索引
                1. 也是构造一个B+树，叶子节点不包含行记录的所有数据，只包含键值和一个书签（用于查找与所有相对应的行数据）。
                2. 每张表可以有多个辅助索引。
                3. 通过建立辅助索引来查找数据时，遍历辅助索引通过叶级别指针来获得指向主键索引的主键，然后通过主键来找到完整的行记录。
            3. 当Innodb监控的二级索引（辅助索引）被频繁访问时，二级索引就变成热点数据，就会建立一个hash索引带来速度提升（hash索引通过缓冲池的B+树构造而来，所以建立的时候很快），缺点是hash自适应索引会占用innodb的buffer pool，自适应hash索引只能用于等值查询，不能范围查找。

        * 答 主键，唯一性索引，外键，联合索引，覆盖索引，哈希索引，前缀索引。
    3. innodb的数据结构你知道哪几种（当时只答了一种B树），还有链表（上面有提到），hash表，queue消息队列，栈
    4. 你觉得加上索引性能就能提高吗？ 
        1. 为什么能提高性能：
            1. 通过创建唯一性索引，可以保证数据库表中每一行数据的唯一性。
            2. 可以大大加快数据的检索速度，这也是创建索引的最主要的原因。
            3. 可以加速表和表之间的连接，特别是在实现数据的参考完整性方面特别有意义。
            4. 在使用分组和排序子句进行数据检索时，同样可以显著减少查询中分组和排序的时间。
            5. 第五，通过使用索引，可以在查询的过程中，使用优化隐藏器，提高系统的性能。
        2. 有的时候不能提高性能：
            1. 创建索引和维护索引要耗费时间，这种时间随着数据量的增加而增加。 
            2. 索引需要占物理空间，除了数据表占数据空间之外，每一个索引还要占一定的物理空间，如果要建立聚集索引那么需要的空间就会更大。 
            3. 当对表中的数据进行增加、删除和修改的时候，索引也要动态的维护，这样就降低了数据的维护速度。
            * 因为索引非常占内存，所以索引也需要谨慎添加，那些字段需要索引。
4. Map,List,Set有共同实现某个接口或者类吗？（当时居然答了有共同实现的接口，卧槽，hape，确实是懵了，只有他们实现的子类，比如HashMap···,HashSet···,ArrayList···才实现了共同的接口Cloneable，Serializable，当时答的就是这两个）
    1. [img](..\..\..\static\img\Map,Set,List继承关系.png)
    2. 三个集合类的差异：
        1. List中的元素，有序、可重复、可为空；
        2. Set中的元素，无序、不重复、只有一个空元素；
        3. Map中的元素，无序、键不重，值可重、可一个空键、多可空值；
    3. 追问如果父类继承了某个类，子类可以使用吗？
        1. 屁话，当然是可以，面试的时候想那么多干嘛，基本的子类继承父类关系啊
    4. 问ArrayList底层实现
        1. 答： 数组实现，当存储的值达到阈值时，进行1.5倍扩容
        2. 追问： 那你觉得ArrayList在什么时候的性能最差 => 当add值正好超过它的阈值，数组进行System.arrayCopy扩容时。还有就是对list数组头处增加删除元素的时候性能最差，但在list尾部删除添加就不会影响性能。
    5. HashMap是怎么实现的，能详细说说put操作吗？
        1. HashMap是根据Hashtable实现的，Hashtable是根据数组加链表实现的。
            1. 追问：你能说说为什么要使用到数组，它是怎么起作用的吗？[img](..\..\..\static\img\Hashtable的底层实现.jpg)
        2. 首先问hashMap是怎么判断元素相等的 => 先是去看key 字符串相不相等，再去比较value值是否相等。为什么不比较hashcode，因为不同的key和value计算出的hashCode可能是相同的。
        3. put之前，先计算key值的hashCode，这个hashCode是个int型的值，计算出来的这个值就是数据在数组中的索引。所以，get的时候，当然也是计算key的hashCode，然后直接从数组中取出数即可。所以get的速度是很快的，没有查找的过程，时间复杂度是O(1)。那前面说过，这个不同的key值的hashCode是可能相同的，也就是hash碰撞，那怎么处理呢？这就是链表的作用了，hashCode相同的key值在数组中的索引就是一样的。于是hashCode相同的这些值就被存放在一个链表上。查找的时候就循环这个链表进行查找。
    6. 因为上面答了Serializable，所以又追问了序列化，你熟悉序列化吗，说说序列化的作用，在你用到的那些框架里面有序列化，你自己用到过序列化吗？
        1. 如果一个类想被序列化，需要实现Serializable接口。否则将抛出NotSerializableException异常，这是因为，在序列化操作过程中会对类型进行检查，要求被序列化的类必须属于Enum、Array和Serializable类型其中的任何一种。
        2. 通过ObjectOutputStream和ObjectInputStream对对象进行序列化及反序列化
        3. 虚拟机是否允许反序列化，不仅取决于类路径和功能代码是否一致，一个非常重要的一点是两个类的序列化 ID 是否一致（就是 private static final long serialVersionUID）
        4. 序列化并不保存静态变量。
        5. 要想将父类对象也序列化，就需要让父类也实现Serializable 接口。
        6. Transient 关键字的作用是控制变量的序列化，在变量声明前加上该关键字，可以阻止该变量被序列化到文件中，在被反序列化后，transient 变量的值被设为初始值，如 int 型的是 0，对象型的是 null。
        7. 服务器端给客户端发送序列化对象数据，对象中有一些数据是敏感的，比如密码字符串等，希望对该密码字段在序列化时，进行加密，而客户端如果拥有解密的密钥，只有在客户端进行反序列化时，才可以对密码进行读取，这样可以一定程度保证序列化对象的数据安全。
        8. 在序列化过程中，如果被序列化的类中定义了writeObject 和 readObject 方法，虚拟机会试图调用对象类里的 writeObject 和 readObject 方法，进行用户自定义的序列化和反序列化。如果没有这样的方法，则默认调用是 ObjectOutputStream 的 defaultWriteObject 方法以及 ObjectInputStream 的 defaultReadObject 方法。用户自定义的 writeObject 和 readObject 方法可以允许用户控制序列化的过程，比如可以在序列化的过程中动态改变序列化的数值。
        9. 序列化作用：序列化将对象编码成字节流，主要用于对象的持久化，远程通信，跨进程访问等地方。java中的序列化机制能够将一个实例对象的状态信息写入到一个字节流中使其可以通过socket进行传输、或者持久化到存储数据库或文件系统中；然后在需要的时候通过字节流中的信息来重构一个相同的对象。
        * 参考 [深入分析Java的序列化与反序列化](http://www.hollischuang.com/archives/1140#What%20Serializable%20Did)

5. 说说反射有哪几种加载方式，你在项目上使用到过反射吗？
    1. Class.forName("全限定类名");
    2. 实例对象.getClass();
    3. 类名.class
    4. 使用过，当时使用反射来获取传入的类来构造一个对象，装入从数据库查询得到的值再返回
```java
while (resultSet.next()) {
			// 利用反射创建对象
			entity = clazz.newInstance();
			for (int i = 0; i < rsmd.getColumnCount(); i++) {
				String columnLabel = rsmd.getColumnLabel(i + 1);
				Object columnValue = resultSet.getObject(i + 1);
				// System.out.println(columnLabel + columnValue);
				Field field = clazz.getDeclaredField(columnLabel);// 获取属性
				field.setAccessible(true);// 打开访问权限
				field.set(entity, columnValue);// 赋值
			}
			list.add(entity);// 将实例传入list中
		}
```


```java
MyClass myClass = new MyClass(0); // 一般做法 
myClass.increase(2);
System.out.println("Normal -> " + myClass.count);
try {
    Constructor constructor = MyClass.class.getConstructor(int.class); // 获取构造方法

    MyClass myClassReflect = constructor.newInstance(10); // 创建对象

    Method method = MyClass.class.getMethod("increase", int.class);  // 获取方法

    method.invoke(myClassReflect, 5); // 调用方法

    Field field = MyClass.class.getField("count"); // 获取域

    System.out.println("Reflect -> " + field.getInt(myClassReflect)); // 获取域的值

} catch (Exception e) { 

    e.printStackTrace();

} 
```