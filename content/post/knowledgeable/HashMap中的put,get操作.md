## put操作
1. 从定义可以看到，put之前，先计算key值的hashCode，这个hashCode是个int型的值，计算出来的这个值就是数据在数组中的索引。所以，get的时候，当然也是计算key的hashCode，然后直接从数组中取出数即可。所以get的速度是很快的，没有查找的过程，时间复杂度是O(1)。那前面说过，这个不同的key值的hashCode是可能相同的，也就是hash碰撞，那怎么处理呢？这就是链表的作用了，hashCode相同的key值在数组中的索引就是一样的。于是hashCode相同的这些值就被存放在一个链表上。查找的时候就循环这个链表进行查找。
```java
if ((tab = table) == null || (n = tab.length) == 0)

            n = (tab = resize()).length;
```
2. 这一段是说如果table为空的时候，就给这个table初始化，也就是resize。这里大致说说这个resize，如果table为空，就将table初始化为一个长度为16的，负载因子为0.75的数组。否则就初始化为之前table长度的两倍。这个时候这个数组的大小为16，但是容量只有16*0.75=12。门限值=容量*负载因子。一旦数组中的元素超过门限值，就会重新resize。这些在代码中都能看到。接下来再看这段：
```java
    if ((p = tab[i = (n - 1) & hash]) == null)

            tab[i] = newNode(hash, key, value, null);
```
3. 这段就很简单了，直接查看这个hash值在数组中的位置，如果这个位置上的值为空，就把值放在这里。接下来是这个if的else，也就是计算的位置上数据不为空的情况：
```java
else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
```
4. 这个else的核心思路就是说，既然这个位置的数据不为空，我新来的数据也插入在这里，和之前的数据一起形成一个链表。所以我就定义一个e节点，这个e节点就是我要插入的位置，我只要找到这个e，并插入数据就完事儿。接下来我们来看看怎么找的e。
```java
if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))

                e = p;
```
5. 这个if是说，你新来的数据，不仅hash值相同，而且还和之前的key值equal，那肯定就是key值相同，就是说你现在put进来的key值之前的map里面就有，当然我就把这个节点返回给你了，你在这个节点上操作就行，所以是e=p;
```java
else if (p instanceof TreeNode)

                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
```
6. 接下来是一个else，这个else if的意思是说，如果节点是TreeNode型的话，就调用TreeNode方法的put方法，这里就不展开说TreeNode的put方法了。无外乎就是树的查找方法。
```java
else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
```
7. 再接下来这个else的意思就是说，hash相同，但是不equals的数据，就循环这个链表，如果遇到的节点为空，就将数据插入到这个空节点上，如果遇到的节点值equals相同（证明又遇到了key值相同的情况），又将这个节点记录并返回。
8. 所以通过以上步骤，我们已经获得了插入数据的位置，这个时候这个位置可能为空，可能不为空。为空就是说你这次put过来的key值之前并不存在于map中，所以分配给你一个空位置。如果不为空，则说明你这次给的key值我之前的map里面已经有这个元素了，就把之前的位置给你返回过来。所以就有下面的判断了
```java
if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;

            }
```
9. 如果e不为空，还要判断一个参数onlyIfAbsent ，这个参数是决定要不要新值替换旧值，如果替换旧值，就将旧值记录并返回。如果是有值的话，在上面就已经插入了，所以现在也不再需要插入的操作了。所以到此为止的话，新来的数儿已经放好了，接下来就是一些善后操作，很简单。
```java
++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);

        return null;
```
10. 这个modCount是记录数据被修改的次数，目前我还不知到这个数儿有什么用。暂且不管。重要的是这个size，这个size是当前map的大小，先自增一下，如果超过了门限值，就要调用resize方法重新分配空间，这就是本文开始的时候提到的resize了。再接下来就是afterNodeInsertion(evict)，好吧我也没明白这是干啥的，用处好像并不大。如有大神知道是干啥用的，还请指点。这样的话，put操作就完事儿了。接下来是get操作。

## get操作
get的时候，先计算key的hash值，肯定就是根据这个hash值去数组中找数据了。再看：
```java
    /**
     * Implements Map.get and related methods
     *
     * @param hash hash for key
     * @param key the key
     * @return the node, or null if none
     */
    final Node<K,V> getNode(int hash, Object key) {
        Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (first = tab[(n - 1) & hash]) != null) {
            if (first.hash == hash && // always check first node
                ((k = first.key) == key || (key != null && key.equals(k))))
                return first;
            if ((e = first.next) != null) {
                if (first instanceof TreeNode)
                    return ((TreeNode<K,V>)first).getTreeNode(hash, key);
                do {
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        return e;
                } while ((e = e.next) != null);
            }
        }
        return null;
    }
```
2. 最外层的if是说如果table为空或者当前位置的数据为空，当然就直接就返回空值啦。再看：
3. hash值相等并且key值相等或者equal的话，就返回这个位置的值。这里这个小细节注意一下，本来这里是个链表，按理说我们应该要循环这个链表取数，但是并没有，为啥？这就要追溯到hash碰撞的问题上了，只有hash值相同但不是相同的key值才会在一条链表上，然而不同key值hash相同（就是hash碰撞）这种几率非常小，所以链表的长度几乎都是1。所以这里就没有用循环，直接先看第一个元素，如果是就直接返回了，省去了循环的开支。当然，如果真的发生了hash碰撞，那也只有循环链表取数了，那其实就是接下来的代码。
4. 再接下来，当然有个是否是TreeNode的判断，如果是的话，就走TreeNode的get方法，这个我也不展开说了。直到循环到找到数据为止。这样，get也就完了。


* 大致总结了一下，hashMap里面的table使用了数组+链表的这个结构存储数据，put和get的时候几乎都不需要查找（只有发生hash碰撞的时候才会有循环，然而这种几率灰常小，所以是几乎不用查找），时间复杂度是O(1)，所以put和get的效率都非常高。直接计算hash值就能得到存储的索引。