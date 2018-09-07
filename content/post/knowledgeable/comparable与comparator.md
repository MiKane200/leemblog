## Comparator 和 Comparable 比较

##### Comparable是排序接口；若一个类实现了Comparable接口，就意味着“该类支持排序”。
##### 而Comparator是比较器；我们若需要控制某个类的次序，可以建立一个“该类的比较器”来进行排序。

##### 不难发现：Comparable相当于“内部比较器”，而Comparator相当于“外部比较器”。

### 代码：
1. Person类定义。如下：
```java
private static class Person implements Comparable<Person>{
    int age;
    String name;
        
        ...

    /** 
     * @desc 实现 “Comparable<String>” 的接口，即重写compareTo<T t>函数。
     *  这里是通过“person的名字”进行比较的
     */
    @Override
    public int compareTo(Person person) {
        return name.compareTo(person.name);
        //return this.name - person.name;
    }   
} 

//Person类代表一个人，Persong类中有两个属性：age(年纪) 和 name“人名”。
// Person类实现了Comparable接口，因此它能被排序。
```

2. 在main()中，我们创建了Person的List数组(list)。如下：
```java
// 新建ArrayList(动态数组)
ArrayList<Person> list = new ArrayList<Person>();
// 添加对象到ArrayList中
list.add(new Person("ccc", 20));
list.add(new Person("AAA", 30));
list.add(new Person("bbb", 10));
list.add(new Person("ddd", 40));
```

3. 接着，我们打印出list的全部元素。如下：
```java
// 打印list的原始序列
System.out.printf("Original sort, list:%s\n", list);
 ```

4. 然后，我们通过Collections的sort()函数，对list进行排序。由于Person实现了Comparable接口，因此通过sort()排序时，会根据Person支持的排序方式，即 compareTo(Person person) 所定义的规则进行排序。如下：
```java
// 对list进行排序
// 这里会根据“Person实现的Comparable<String>接口”进行排序，即会根据“name”进行排序
Collections.sort(list);
System.out.printf("Name sort, list:%s\n", list);
```

5. 对比Comparable和Comparator,我们定义了两个比较器 AscAgeComparator 和 DescAgeComparator，来分别对Person进行 升序 和 降低 排序。

6. AscAgeComparator比较器,它是将Person按照age进行升序排序。代码如下：
```java
/**
 * @desc AscAgeComparator比较器
 *       它是“Person的age的升序比较器”
 */
private static class AscAgeComparator implements Comparator<Person> {

    @Override
    public int compare(Person p1, Person p2) {
        return p1.getAge() - p2.getAge();
    }
}
```

7. DescAgeComparator比较器,它是将Person按照age进行降序排序。代码如下：
```java
/**
 * @desc DescAgeComparator比较器
 *       它是“Person的age的升序比较器”
 */
private static class DescAgeComparator implements Comparator<Person> {

    @Override
    public int compare(Person p1, Person p2) {
        return p2.getAge() - p1.getAge();
    }
}
```

8. 调用comparator排序
```java
Collections.sort(list, new AscAgeComparator());
Collections.sort(list, new DescAgeComparator());
```