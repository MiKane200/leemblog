## Vector、ArrayList、LinkedList均为线型的数据结构，但是从实现方式与应用场景中又存在差别。
1. 底层实现方式
ArrayList内部用数组来实现；LinkedList内部采用双向链表实现；Vector内部用数组实现。
2. 读写机制
    1. ArrayList在执行插入元素是超过当前数组预定义的最大值时，数组需要扩容，扩容过程需要调用底层System.arraycopy()方法进行大量的数组复制操作；在删除元素时并不会减少数组的容量（如果需要缩小数组容量，可以调用trimToSize()方法）；在查找元素时要遍历数组，对于非null的元素采取equals的方式寻找。
    2. LinkedList在插入元素时，须创建一个新的Entry对象，并更新相应元素的前后元素的引用；在查找元素时，需遍历链表；在删除元素时，要遍历链表，找到要删除的元素，然后从链表上将此元素删除即可。
    3. Vector与ArrayList仅在插入元素时容量扩充机制不一致。对于Vector，默认创建一个大小为10的Object数组，并将capacityIncrement设置为0；当插入元素数组大小不够时，如果capacityIncrement大于0，则将Object数组的大小扩大为现有size+capacityIncrement；如果capacityIncrement<=0,则将Object数组的大小扩大为现有大小的2倍。
3. 读写效率
    1. ArrayList对元素的增加和删除都会引起数组的内存分配空间动态发生变化(超过才会扩容)。(因此，对其进行插入和删除速度较慢，但检索速度很快)=>错误！！！，不能这么绝对.
        1. 并不是所有的增删都会开辟新内存，没有开辟新内存的尾部增，效率也是杠杠的。
        2. 尾部删除也不需要开辟新内存，只是移出最后一个对象。
        3. 直接导致结果就是本身适合使用ArrayList的场景会因为这个笼统的说法而选LinkedList。
LinkedList由于基于链表方式存放数据，增加和删除元素的速度较快，但是检索速度较慢。
4. 线程安全性
ArrayList、LinkedList为非线程安全；Vector是基于synchronized实现的线程安全的ArrayList。
需要注意的是：单线程应尽量使用ArrayList，Vector因为同步会有性能损耗；即使在多线程环境下，我们可以利用Collections这个类中为我们提供的synchronizedList(List list)方法返回一个线程安全的同步列表对象。
  精选第一个对于读写效率问题，我觉得表述有问欠缺，或者说不能那么绝对。 