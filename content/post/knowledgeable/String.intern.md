## String存在的stringtable
java中所有的类共享一个字符串常量池。比如A类中需要一个“hello”的字符串常量，B类也需要同样的字符串常量，他们都是从字符串常量池中获取的字符串，并且获得得到的字符串常量的地址是一样的。
实际上，为了提高匹配速度，即更快的查找某个字符串是否存在于常量池，Java在设计字符串常量池的时候，还搞了一张stringtable，stringtable有点类似于我们的hashtable，里面保存了字符串的引用。我们可以根据字符串的hashcode找到对应entry，如果没冲突，它可能只是一个entry，如果有冲突，它可能是一个entry链表，然后Java再遍历entry链表，匹配引用对应的字符串，如果找得到字符串，返回引用，如果找不到字符串，会把字符串放到常量池中，并把引用保存到stringtable里。

## 怎么样才能进入字符串常量池 -- 只有执行了ldc指令的字符串才会进入字符串常量池

#### 凡是有双引号括起字符串的地方就会用到ldc指令,比如上面的String a = "hello"。
1. 我们执行完main以后，hello不会进入字符串常量池。因为String a = "hello"是ClassPoolTest 的成员变量，成员变量只有在执行到构造方法的时候才会初始化。
```java
public class ClassPoolTest {
    String a = "hello";
    public static void main(String[] args) {}
}
```
2. 执行完main以后，hello会进入常量池，因为static String a = "hello"是ClassPoolTest 静态变量，我们执行静态方法main之后张初始化静态变量
```java
public class ClassPoolTest {
    static String a = "hello";
    public static void main(String[] args) {}
}
```
#### intern的作用是把new出来的字符串的引用添加到stringtable中，java会先计算string的hashcode，查找stringtable中是否已经有string对应的引用了，如果有返回引用（地址），然后没有把字符串的地址放到stringtable中，并返回字符串的引用（地址）。
1. 因为有双引号括起来的字符串，所以会把ldc命令，即"haha"会被我们添加到字符串常量池，它的引用是string的char数组的地址，会被我们添加到stringtable中。所以a.intern的时候，返回的其实是string中的char数组的地址，和a的string实例化地址肯定是不一样的。
```java
    public static void main(String[] args) {
        String a = new String("haha");
        System.out.println(a.intern() == a);//false
    }
```
2. new String("jo") + new String("hn")实际上会转为stringbuffer的append 然后tosring()出来，实际上是new 一个新的string出来。在这个过程中，并没有双引号括起john，也就是说并不会执行ldc然后把john的引用添加到stringtable中，所以intern的时候实际就是把新的string地址（即e的地址）添加到stringtable中并且返回回来。
```java
String e = new String("jo") + new String("hn");
        System.out.println(e.intern() == e);//true
```