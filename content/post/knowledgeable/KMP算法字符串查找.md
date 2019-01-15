## 朴素查找方法
存在很多缺陷：主串见一个，匹配串查一个，挨着查，不对就从上一次查的起始位置的下一个开始查。见下面初级next数组方法说明KMP优越性
```java
    static int simpleIndexOf(String source, String pattern) {
        int i = 0, j = 0;
        int sLen = source.length(), pLen = pattern.length();
        char[] src = source.toCharArray();
        char[] ptn = pattern.toCharArray();
        int flag = 0;
        while (i < sLen && j < pLen) {
            if (src[i] == ptn[j]) {
                // 如果当前字符匹配成功,则将两者各自增1,继续比较后面的字符
                i++;
                j++;
            } else {
                // 如果当前字符匹配不成功,则i回溯到此次匹配最开始的位置+1处,也就是i = i - j + 1
                // (因为i,j是同步增长的), j = 0;
                i = i - j + 1;
                j = 0;
            }
            if (j == pLen) {
                i = i - j + 1;
                j = 0;
                flag++;
            }
        }
        return flag;
    }
```

## KMP
#### 原始：怎么得到next数组呢？
比如举个例子：abcab=>数组应该是：-10001。 aaaax=> -10123

#### 初级得到next数组的方法： 
比如有str = adsdf abca c bcab与要被匹配的 ptr = abcab，如果当走到str的abca 时继续往下匹配发现c！=b，所以将j赋值为next[j]用到next里面的数即j=1=>相当于把j回溯到abcab中的第一个b这个位置（如果此处是c变为b的话就少了比较前面一个a的这个步骤，此处就是提升性能处），就不用回溯到a了，减少了重复比较a。

* 其实为什么要把j这个值赋给next数组中呢？因为如果匹配到一个相同的就会i++，相应j就会++，所以把j赋到数组相当于把重复次数赋到数组！理所当然的，后面不等的时候就把j清为上一个重复值处KMP算法的相应的next数组处。

```java
    static int[] getNext(char[] p) {
        int pLen = p.length;
        int[] next = new int[pLen];
        int j = -1;
        int i = 0;
        next[0] = -1; // next数组中next[0]为-1
        while (i < pLen - 1) {
            if (j == -1 || p[i] == p[j]) {
                j++;
                i++;
                next[i] = j;
            } else {
                j = next[j];
            }
        }
        return next;
    }
```

#### 优化得到next数组方法：
aaaax=> -10123存在什么问题呢？比如主串为aaabcbx，当匹配到i=4,b=4的时候a!=b，所以j=next[j]=3,还是a!=b,j=2还是a!=b，balabala···，重复去一个个比较j为-1,0,1,2的情况。
怎么优化呢？=> 在如果前缀后缀匹配相等时候加个判断，如果相等则 => next[i] = next[j];
```java
    static int[] getOptimumNext(char[] p) {
        int pLen = p.length;
        int[] next = new int[pLen];
        int j = -1;
        int i = 0;
        next[0] = -1;
        while (i < pLen - 1) {
            if (j == -1 || p[i] == p[j]) {
                j++;
                i++;
                // 修改next数组求法
                if (p[i] != p[j]) {
                    next[i] = j;
                } else {
                    next[i] = next[j];
                }
            } else {
                j = next[j];
            }
        }
        return next;
    }
```

#### 主方法
```java
    static int KMPIndexOf(String source, String pattern) {
        int i = 0, j = 0;
        char[] src = source.toCharArray();
        char[] ptn = pattern.toCharArray();
        int sLen = src.length;
        int pLen = ptn.length;
        int[] next = getOptimumNext(ptn);
        int flag = 0;
        while (i < sLen && j < pLen) {
            // 如果j = -1,或者当前字符匹配成功, 就继续往下匹配，直到匹配到j==pLen就加1表匹配到完整字符串
            if (j == -1 || src[i] == ptn[j]) {
                i++;
                j++;
            } else {
                // 让i不动，j回溯
                j = next[j];
            }
            if (j == pLen) {
                flag++;
                i= i - j + 1; //加上这行代码就可以匹配出如 abcabcab为两次出现了，不加就只能匹配abcab一次出现
                j = 0;
            }
        }
        return flag;
    }
```