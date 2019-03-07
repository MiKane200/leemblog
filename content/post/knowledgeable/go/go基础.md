## go 的 hello world
1. package main 定义了包名。你必须在源文件中非注释的第一行指明这个文件属于哪个包，如：package main。package main表示一个可独立执行的程序，每个 Go 应用程序都包含一个名为 main 的包。
2. main 函数是每一个可执行程序所必须包含的，一般来说都是在启动后第一个执行的函数（如果有 init() 函数则会先执行该函数）。
3. 当标识符（包括常量、变量、类型、函数名、结构字段等等）以一个大写字母开头，如：Group1，那么使用这种形式的标识符的对象就可以被外部包的代码所使用（客户端程序需要先导入这个包），这被称为导出（像面向对象语言中的 public）；标识符如果以小写字母开头，则对包外是不可见的，但是他们在整个包的内部是可见并且可用的（像面向对象语言中的 protected ）。
4. 需要注意的是 { 不能单独放在一行，所以以下代码在运行时会产生错误：
```go
package main

import "fmt"

func main()  
{  // 错误，{ 不能在单独的行上
    fmt.Println("Hello, World!")
}
```

## go基础语法
1. 在 Go 程序中，一行代表一个语句结束。每个语句不需要像 C 家族中的其它语言一样以分号 ; 结尾，因为这些工作都将由 Go 编译器自动完成。
2. 如果你打算将多个语句写在同一行，它们则必须使用 ; 人为区分，但在实际开发中我们并不鼓励这种做法。
标识符用来命名变量、类型等程序实体。一个标识符实际上就是一个或是多个字母(A~Z和a~z)数字(0~9)、下划线_组成的序列，但是第一个字符必须是字母或下划线而不能是数字。
3. 下面列举了 Go 代码中会使用到的 25 个关键字或保留字：
    break	default	func	interface	select
    case	defer	go	map	struct
    chan	else	goto	package	switch
    const	fallthrough	if	range	type
    continue	for	import	return	var
4. 除了以上介绍的这些关键字，Go 语言还有 36 个预定义标识符：
    append	bool	byte	cap	close	complex	complex64	complex128	uint16
    copy	false	float32	float64	imag	int	int8	int16	uint32
    int32	int64	iota	len	make	new	nil	panic	uint64
    print	println	real	recover	string	true	uint	uint8	uintptr
5. 变量声明
    1. 第一种，指定变量类型，声明后若不赋值，使用默认值。
    ```go
    var v_name v_type
    v_name = value
    ```
    2. 第二种，根据值自行判定变量类型。
    ```go
    var v_name = value
    ```
    3. 第三种，省略var, 注意 :=左侧的变量不应该是已经声明过的，否则会导致编译错误。
    ```go
    v_name := value
    ```
    4. 实例
    ```go
    // 例如
    var a int = 10
    var b = 10
    c := 10
    ```
6. 多变量声明
```go
//类型相同多个变量, 非全局变量
var vname1, vname2, vname3 type
vname1, vname2, vname3 = v1, v2, v3

var vname1, vname2, vname3 = v1, v2, v3 //和python很像,不需要显示声明类型，自动推断

vname1, vname2, vname3 := v1, v2, v3 //出现在:=左侧的变量不应该是已经被声明过的，否则会导致编译错误


// 这种因式分解关键字的写法一般用于声明全局变量
var (
    vname1 v_type1
    vname2 v_type2
)
```
7. 所有像 int、float、bool 和 string 这些基本类型都属于值类型，使用这些类型的变量直接指向存在内存中的值,当使用等号 = 将一个变量的值赋值给另一个变量时，如：j = i，实际上是在内存中将 i 的值进行了拷贝
8. 可以通过 &i 来获取变量 i 的内存地址,这个内存地址为称之为指针，这个指针实际上也被存在另外的某一个字中。同一个引用类型的指针指向的多个字可以是在连续的内存地址中（内存布局是连续的），这也是计算效率最高的一种存储形式；也可以将这些字分散存放在内存中，每个字都指示了下一个字所在的内存地址。当使用赋值语句 r2 = r1 时，只有引用（地址）被复制。,如果 r1 的值被改变了，那么这个值的所有引用都会指向被修改后的内容，在这个例子中，r2 也会受到影响。 这一点跟java的引用类型一样。
9. 如果你想要交换两个变量的值，则可以简单地使用 a, b = b, a，两个变量的类型必须是相同。
10. 空白标识符 _ 也被用于抛弃值，如值 5 在：_, b = 5, 7 中被抛弃。_ 实际上是一个只写变量，你不能得到它的值。这样做是因为 Go 语言中你必须使用所有被声明的变量，但有时你并不需要使用从一个函数得到的所有返回值。并行赋值也被用于当一个函数返回多个返回值时。
```go
package main

import "fmt"

func main() {
  _,numb,strs := numbers() //只获取函数返回值的后两个
  fmt.Println(numb,strs)
}

//一个可以返回多个值的函数
func numbers()(int,int,string){
  a , b , c := 1 , 2 , "str"
  return a,b,c
}
```

* 注意：如果你声明了一个局部变量却没有在相同的代码块中使用它，会得到编译错误，例如下面这个例子当中的变量 a,但是全局变量是允许声明但不使用
```go
func main() {
   var a string = "abc"
   fmt.Println("hello, world")
}
```

## 常量
1. 常量是一个简单值的标识符，在程序运行时，不会被修改的量，常量中的数据类型只可以是布尔型、数字型（整数型、浮点型和复数）和字符串型。
2. const identifier [type] = value //type可以省略
3. 常量还可以用作枚举：
```go
package main

import "unsafe"
const (
    a = "abc"
    b = len(a)
    c = unsafe.Sizeof(a)
)

func main(){
    println(a, b, c)
}
```
4. iota，特殊常量，可以认为是一个可以被编译器修改的常量。iota 在 const关键字出现时将被重置为 0(const 内部的第一行之前)，const 中每新增一行常量声明将使 iota 计数一次(iota 可理解为 const 语句块中的行索引)。
```go
package main

import "fmt"

func main() {
    const (
            a = iota   //0
            b          //1
            c          //2
            d = "ha"   //独立值，iota += 1
            e          //"ha"   iota += 1
            f = 100    //iota +=1
            g          //100  iota +=1
            h = iota   //7,恢复计数
            i          //8
    )
    fmt.Println(a,b,c,d,e,f,g,h,i)
}
//运行结果为：
//0 1 2 ha ha 100 100 7 8
```

## 运算符
#### 位运算符 &, |, 和 ^ 的计算：

p	q	p & q	p | q	p ^ q
0	0	0	    0	    0
0	1	0	    1	    1
1	1	1	    1	    0
1	0	0	    1	    1

#### 运算符的优先级
优先级	运算符
7	    ^ !
6	    * / % << >> & &^
5	    + - | ^
4	    == != < <= >= >
3	    <-
2	    &&
1	    ||