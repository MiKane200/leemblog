## NIO
#### Buffer基本用法:
1. 利用Buffer读写数据，通常遵循四个步骤：
    1. 把数据写入buffer；
    2. 调用flip；
    3. 从Buffer中读取数据；
    4. 调用buffer.clear()或者buffer.compact()
    * tips: 当写入数据到buffer中时，buffer会记录已经写入的数据大小。当需要读数据时，通过flip()方法把buffer从写模式调整为读模式；在读模式下，可以读取所有已经写入的数据。当读取完数据后，需要清空buffer，以满足后续写入操作。清空buffer有两种方式：调用clear()或compact()方法。clear会清空整个buffer，compact则只清空已读取的数据，未被读取的数据会被移动到buffer的开始位置，写入位置则近跟着未读数据之后。
2. Buffer的容量，位置，上限（Buffer Capacity, Position and Limit）
    1. 容量（Capacity）:作为一块内存，buffer有一个固定的大小，叫做capacity容量。也就是最多只能写入容量值得字节，整形等数据。一旦buffer写满了就需要清空已读数据以便下次继续写入新的数据。
    2. 位置（Position）:当写入数据到Buffer的时候需要中一个确定的位置开始，默认初始化时这个位置position为0，一旦写入了数据比如一个字节，整形数据，那么position的值就会指向数据之后的一个单元，position最大可以到capacity-1.当从Buffer读取数据时，也需要从一个确定的位置开始。buffer从写入模式变为读取模式时，position会归零，每次读取后，position向后移动。
    3. 上限（Limit）:在写模式，limit的含义是我们所能写入的最大数据量。它等同于buffer的容量。一旦切换到读模式，limit则代表我们所能读取的最大数据量，他的值等同于写模式下position的位置。数据读取的上限时buffer中已有的数据，也就是limit的位置（原position所指的位置）。


## BIO、NIO、AIO适用场景分析: 
1. BIO方式适用于连接数目比较小且固定的架构，这种方式对服务器资源要求比较高，并发局限于应用中，JDK1.4以前的唯一选择，但程序直观简单易理解。 
2. NIO方式适用于连接数目多且连接比较短（轻操作）的架构，比如聊天服务器，并发局限于应用中，编程比较复杂，JDK1.4开始支持。 
3. AIO方式使用于连接数目多且连接比较长（重操作）的架构，比如相册服务器，充分调用OS参与并发操作，编程比较复杂，JDK7开始支持。 