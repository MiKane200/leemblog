## 本地化日期时间 API   LocalDate/LocalTime 和 LocalDateTime 类可以在处理时区不是必须的情况。
```java
Java8Tester.java 文件
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.time.Month;
 
public class Java8Tester {
   public static void main(String args[]){
      Java8Tester java8tester = new Java8Tester();
      java8tester.testLocalDateTime();
   }
    
   public void testLocalDateTime(){
    
      // 获取当前的日期时间
      LocalDateTime currentTime = LocalDateTime.now();
      System.out.println("当前时间: " + currentTime);
        
      LocalDate date1 = currentTime.toLocalDate();
      System.out.println("date1: " + date1);
        
      Month month = currentTime.getMonth();
      int day = currentTime.getDayOfMonth();
      int seconds = currentTime.getSecond();
        
      System.out.println("月: " + month +", 日: " + day +", 秒: " + seconds);
        
      LocalDateTime date2 = currentTime.withDayOfMonth(10).withYear(2012);
      System.out.println("date2: " + date2);
        
      // 12 december 2014
      LocalDate date3 = LocalDate.of(2014, Month.DECEMBER, 12);
      System.out.println("date3: " + date3);
        
      // 22 小时 15 分钟
      LocalTime date4 = LocalTime.of(22, 15);
      System.out.println("date4: " + date4);
        
      // 解析字符串
      LocalTime date5 = LocalTime.parse("20:15:30");
      System.out.println("date5: " + date5);
   }
}
```

## 默认方法实例 我们可以通过以下代码来了解关于默认方法的使用，可以将代码放入 Java8Tester.java 文件中：
```java
public class Java8Tester {
   public static void main(String args[]){
      Vehicle vehicle = new Car();
      vehicle.print();
   }
}
 
interface Vehicle {
   default void print(){
      System.out.println("我是一辆车!");
   }
    
   static void blowHorn(){
      System.out.println("按喇叭!!!");
   }
}
 
interface FourWheeler {
   default void print(){
      System.out.println("我是一辆四轮车!");
   }
}
 
class Car implements Vehicle, FourWheeler {
   public void print(){
      Vehicle.super.print();
      FourWheeler.super.print();
      Vehicle.blowHorn();
      System.out.println("我是一辆汽车!");
   }
}
```


## stream

#### map转换为list
```java
// Java 8, Convert all Map values  to a List
List<String> result4 = map.values().stream()
	.collect(Collectors.toList());
// Java 8, seem a bit long, but you can enjoy the Stream features like filter and etc.
List<String> result5 = map.values().stream()
	.filter(x -> !"apple".equalsIgnoreCase(x))
	.collect(Collectors.toList());
```
#### list转array
```java
    //resultRelDTOS => TestIssueFolderRelDTO的list
    Long[] issueIds = resultRelDTOS.stream().map(TestIssueFolderRelDTO::getIssueId).toArray(Long[]::new);
 ```


## Optional
存在即返回, 无则提供默认值
return user.orElse(null);  //而不是 return user.isPresent() ? user.get() : null;
return user.orElse(UNKNOWN_USER);
存在即返回, 无则由函数来产生
return user.orElseGet(() -> fetchAUserFromDatabase()); //而不要 return user.isPresent() ? user: fetchAUserFromDatabase();
存在才对它做点什么
user.ifPresent(System.out::println);
 
//而不要下边那样
if (user.isPresent()) {
  System.out.println(user.get());
}

map 函数隆重登场
当 user.isPresent() 为真, 获得它关联的 orders, 为假则返回一个空集合时, 我们用上面的 orElse, orElseGet 方法都乏力时, 那原本就是 map 函数的责任, 我们可以这样

return user.map(u -> u.getOrders()).orElse(Collections.emptyList())
 
//上面避免了我们类似 Java 8 之前的做法
if(user.isPresent()) {
  return user.get().getOrders();
} else {
  return Collections.emptyList();
}
map  是可能无限级联的, 比如再深一层, 获得用户名的大写形式
return user.map(u -> u.getUsername())
           .map(name -> name.toUpperCase())
           .orElse(null);
这要搁在以前, 每一级调用的展开都需要放一个 null 值的判断
User user = .....
if(user != null) {
  String name = user.getUsername();
  if(name != null) {
    return name.toUpperCase();
  } else {
    return null;
  }
} else {
  return null;
}
针对这方面 Groovy 提供了一种安全的属性/方法访问操作符 ?.

user?.getUsername()?.toUpperCase();
Swift 也有类似的语法, 只作用在  Optional 的类型上.

用了 isPresent() 处理 NullPointerException 不叫优雅, 有了  orElse, orElseGet 等, 特别是 map 方法才叫优雅.

其他几个, filter() 把不符合条件的值变为 empty(),  flatMap() 总是与 map() 方法成对的,  orElseThrow() 在有值时直接返回, 无值时抛出想要的异常.

一句话小结: 使用 Optional 时尽量不直接调用 Optional.get() 方法, Optional.isPresent() 更应该被视为一个私有方法, 应依赖于其他像 Optional.orElse(), Optional.orElseGet(), Optional.map() 等这样的方法.

最后, 最好的理解 Java 8 Optional 的方法莫过于看它的源代码 java.util.Optional, 阅读了源代码才能真真正正的让你解释起来最有底气, Optional 的方法中基本都是内部调用  isPresent() 判断, 真时处理值, 假时什么也不做.