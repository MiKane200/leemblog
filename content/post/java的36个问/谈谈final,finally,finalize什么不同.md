1. final可以用来修饰类、方法、变量，分别有不同的意义，final修饰的class代表不可以继承扩展，final的变量是不可以修改的，而final的方法也是不可以重写的（override）。

2. finally则是Java保证重点代码一定要被执行的一种机制。我们可以使用try-finally或者try-catch-finally来进行类似关闭JDBC连接、保证unlock锁等动作。

3. finalize是基础类java.lang.Object的一个方法，它的设计目的是保证对象在被垃圾收集前完成特定资源的回收。finalize机制现在已经不推荐使用，并且在JDK 9开始被标记为deprecated。

## 扩充
try {
  // do something
  System.exit(1);
} finally{
  System.out.println(“Print from finally”);
}
上面finally里面的代码可不会被执行的哦，这是一个特例。

对于finalize，我们要明确它是不推荐使用的，业界实践一再证明它不是个好的办法，在Java 9中，甚至明确将Object.finalize()标记为deprecated！如果没有特别的原因，不要实现finalize方法，也不要指望利用它来进行资源回收。

为什么呢？简单说，你无法保证finalize什么时候执行，执行的是否符合预期。使用不当会影响性能，导致程序死锁、挂起等。

通常来说，利用上面的提到的try-with-resources或者try-finally机制，是非常好的回收资源的办法。如果确实需要额外处理，可以考虑Java提供的Cleaner机制或者其他替代方法。接下来，介绍更多设计考虑和实践细节。

#### 注意，final不是immutable！
我在前面介绍了final在实践中的益处，需要注意的是，final并不等同于immutable，比如下面这段代码：

```java
final List<String> strList = new ArrayList<>();
 strList.add("Hello");
 strList.add("world");  
 List<String> unmodifiableStrList = List.of("hello", "world");
 unmodifiableStrList.add("again");
 ```

final只能约束strList这个引用不可以被赋值，但是strList对象行为不被final影响，添加元素等操作是完全正常的。如果我们真的希望对象本身是不可变的，那么需要相应的类支持不可变的行为。在上面这个例子中，List.of方法创建的本身就是不可变List，最后那句add是会在运行时抛出异常的。

##### immutable
Immutable在很多场景是非常棒的选择，某种意义上说，Java语言目前并没有原生的不可变支持，如果要实现immutable的类，我们需要做到：
1. 将class自身声明为final，这样别人就不能扩展来绕过限制了。
2. 将所有成员变量定义为private和final，并且不要实现setter方法。
3. 通常构造对象时，成员变量使用深度拷贝来初始化，而不是直接赋值，这是一种防御措施，因为你无法确定输入对象不被其他人修改。
4. 如果确实需要实现getter方法，或者其他可能会返回内部状态的方法，使用copy-on-write原则，创建私有的copy。

#### finalize
1. finalize的执行是和垃圾收集关联在一起的，一旦实现了非空的finalize方法，就会导致相应对象回收呈现数量级上的变慢，有人专门做过benchmark，大概是40~50倍的下降。因为，finalize被设计成在对象被垃圾收集前调用，这就意味着实现了finalize方法的对象是个“特殊公民”，JVM要对它进行额外处理。finalize本质上成为了快速回收的阻碍者，可能导致你的对象经过多个垃圾收集周期才能被回收。
2. 从另一个角度，我们要确保回收资源就是因为资源都是有限的，垃圾收集时间的不可预测，可能会极大加剧资源占用。这意味着对于消耗非常高频的资源，千万不要指望finalize去承担资源释放的主要职责，最多让finalize作为最后的“守门员”，况且它已经暴露了如此多的问题。这也是为什么我推荐，资源用完即显式释放，或者利用资源池来尽量重用。
3. catch (Throwable x) { }是的，你没有看错，这里的Throwable是被生吞了的！也就意味着一旦出现异常或者出错，你得不到任何有效信息。况且，Java在finalize阶段也没有好的方式处理任何信息，不然更加不可预测。