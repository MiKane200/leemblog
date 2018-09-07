## 方法一使用keyset value遍历 
```java
Map<Integer, Integer> map = new HashMap<Integer, Integer>();
 
//遍历map中的键
 
for (Integer key : map.keySet()) {
 
    System.out.println("Key = " + key);
 
}
 
//遍历map中的值
 
for (Integer value : map.values()) {
 
    System.out.println("Value = " + value);
}
 ```

## 方法二使用Iterator遍历
```java
//使用泛型：

Map<Integer, Integer> map = new HashMap<Integer, Integer>();
 
Iterator<Map.Entry<Integer, Integer>> entries = map.entrySet().iterator();
 
while (entries.hasNext()) {
 
    Map.Entry<Integer, Integer> entry = entries.next();
 
    System.out.println("Key = " + entry.getKey() + ", Value = " + entry.getValue());
 
}


//不使用泛型：

Map map = new HashMap();
 
Iterator entries = map.entrySet().iterator();
 
while (entries.hasNext()) {
 
    Map.Entry entry = (Map.Entry) entries.next();
 
    Integer key = (Integer)entry.getKey();
 
    Integer value = (Integer)entry.getValue();
 
    System.out.println("Key = " + key + ", Value = " + value);
 
}
```
