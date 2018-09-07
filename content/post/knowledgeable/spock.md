4.3.Spock中的概念
4.3.1.Specification
在Spock中，待测系统(system under test; SUT) 的行为是由规格(specification) 所定义的。在使用Spock框架编写测试时，测试类需要继承自Specification类。

4.3.2.Fields
Specification类中可以定义字段，这些字段在运行每个测试方法前会被重新初始化，跟放在setup()里是一个效果。


def obj = new ClassUnderSpecification()
def coll = new Collaborator()
4.3.3.Fixture Methods
预先定义的几个固定的函数，与junit或testng中类似，不多解释了


def setup() {}          // run before every feature method
def cleanup() {}        // run after every feature method
def setupSpec() {}     // run before the first feature method
def cleanupSpec() {}   // run after the last feature method

4.3.4.Feature methods
这是Spock规格(Specification）的核心，其描述了SUT应具备的各项行为。每个Specification都会包含一组相关的Feature methods，如要测试1+1是否等于2，可以编写一个函数：


def "sum should return param1+param2"() {
    expect:
    sum.sum(1,1) == 2
}
4.3.5.blocks
每个feature method又被划分为不同的block，不同的block处于测试执行的不同阶段，在测试运行时，各个block按照不同的顺序和规则被执行，如下图：

blocks

下面分别解释一下各个block的用途。

4.3.6.Setup Blocks
setup也可以写成given，在这个block中会放置与这个测试函数相关的初始化程序，如：


setup:
def stack = new Stack()
def elem = "push me"
一般会在这个block中定义局部变量，定义mock函数等。

4.3.7.When and Then Blocks
when与then需要搭配使用，在when中执行待测试的函数，在then中判断是否符合预期，如：
when:
stack.push(elem)  

then:
!stack.empty
stack.size() == 1
stack.peek() == elem

4.3.7.1.断言
条件类似junit中的assert，就像上面的例子，在then或expect中会默认assert所有返回值是boolean型的顶级语句。如果要在其它地方增加断言，需要显式增加assert关键字，如：


def setup() {
  stack = new Stack()
  assert stack.empty
}
4.3.7.2.异常断言
如果要验证有没有抛出异常，可以用thrown()，如下：


when:
stack.pop()  

then:
thrown(EmptyStackException)
stack.empty
要获取抛出的异常对象，可以用以下语法：


when:
stack.pop()  

then:
def e = thrown(EmptyStackException)
e.cause == null
如果要验证没有抛出某种异常，可以用notThrown()：


def "HashMap accepts null key"() {
  setup:
  def map = new HashMap()  

  when:
  map.put(null, "elem")  

  then:
  notThrown(NullPointerException)
}
4.3.8.Expect Blocks
expect可以看做精简版的when+then，如：

when:
def x = Math.max(1, 2)  

then:
x == 2
可以简化为：


expect:
Math.max(1, 2) == 2
1
2
expect:
Math.max(1, 2) == 2
4.3.9.Cleanup Blocks
函数退出前做一些清理工作，如关闭资源等。

4.3.10.Where Blocks
where：block始终位于方法的末尾
做测试时最复杂的事情之一就是准备测试数据，尤其是要测试边界条件、测试异常分支等，这些都需要在测试之前规划好数据。但是传统的测试框架很难轻松的制造数据，要么依赖反复调用，要么用xml或者data provider函数之类难以理解和阅读的方式。比如说：


class MathSpec extends Specification {
    def "maximum of two numbers"() {
        expect:
        // exercise math method for a few different inputs
        Math.max(1, 3) == 3
        Math.max(7, 4) == 7
        Math.max(0, 0) == 0
    }
}
而在spock中，通过where block可以让这类需求实现起来变得非常优雅（在最简单（也是最常见）的情况下，where：block保存数据表。）：


class DataDriven extends Specification {
    def "maximum of two numbers"() {
        expect:
        Math.max(a, b) == c

        where:
        a | b || c
        3 | 5 || 5
        7 | 0 || 7
        0 | 0 || 0
    }
}
上述例子实际会跑三次测试，相当于在for循环中执行三次测试，a/b/c的值分别为3/5/5,7/0/7和0/0/0。如果在方法前声明@Unroll，则会当成三个方法运行。

更进一步，可以为标记@Unroll的方法声明动态的spec名：


class DataDriven extends Specification {
    @Unroll
    def "maximum of #a and #b should be #c"() {
        expect:
        Math.max(a, b) == c

        where:
        a | b || c
        3 | 5 || 5
        7 | 0 || 7
        0 | 0 || 0
    }
}
运行时，名称会被替换为实际的参数值。

除此之外，where block还有两种数据定义的方法，并且可以结合使用，如：

where:
a | _
3 | _
7 | _
0 | _

b << [5, 0, 0]

c = a > b ? a : b
4.4.Interaction Based Testing
对于测试来说，除了能够对输入-输出进行验证之外，还希望能验证模块与其他模块之间的交互是否正确，比如“是否正确调用了某个某个对象中的函数”；或者期望被调用的模块有某个返回值，等等。

各类mock框架让这类验证变得可行，而spock除了支持这类验证，并且做的更加优雅。如果你还不清楚mock是什么，最好先去简单了解一下，网上的资料非常多，这里就不展开了。

4.4.1.mock
在spock中创建一个mock对象非常简单：


class PublisherSpec extends Specification {
    Publisher publisher = new Publisher()
    Subscriber subscriber = Mock()
    Subscriber subscriber2 = Mock()

    def setup() {
        publisher.subscribers.add(subscriber)
        publisher.subscribers.add(subscriber2)
    }
}
而创建了mock对象之后就可以对它的交互做验证了：


def "should send messages to all subscribers"() {
    when:
    publisher.send("hello")

    then:
    1 * subscriber.receive("hello")
    1 * subscriber2.receive("hello")
}
上面的例子里验证了：在publisher调用send时，两个subscriber都应该被调用一次receive(“hello”)。

示例中，表达式中的次数、对象、函数和参数部分都可以灵活定义：
1 * subscriber.receive("hello")      // exactly one call
0 * subscriber.receive("hello")      // zero calls
(1..3) * subscriber.receive("hello") // between one and three calls (inclusive)
(1.._) * subscriber.receive("hello") // at least one call
(_..3) * subscriber.receive("hello") // at most three calls
_ * subscriber.receive("hello")      // any number of calls, including zero
1 * subscriber.receive("hello")     // an argument that is equal to the String "hello"
1 * subscriber.receive(!"hello")    // an argument that is unequal to the String "hello"
1 * subscriber.receive()            // the empty argument list (would never match in our example)
1 * subscriber.receive(_)           // any single argument (including null)
1 * subscriber.receive(*_)          // any argument list (including the empty argument list)
1 * subscriber.receive(!null)       // any non-null argument
1 * subscriber.receive(_ as String) // any non-null argument that is-a String
1 * subscriber.receive({ it.size() > 3 }) // an argument that satisfies the given predicate
                                          // (here: message length is greater than 3)
1 * subscriber._(*_)     // any method on subscriber, with any argument list
1 * subscriber._         // shortcut for and preferred over the above
1 * _._                  // any method call on any mock object
1 * _                    // shortcut for and preferred over the above
得益于groovy脚本语言的特性，在定义交互的时候不需要对每个参数指定类型，如果用过java下的其它mock框架应该会被这个特性深深的吸引住。

4.4.2.Stubbing
对mock对象定义函数的返回值可以用如下方法：
subscriber.receive(_) >> "ok"

符号代表函数的返回值，执行上面的代码后，再调用subscriber.receice方法将返回ok。如果要每次调用返回不同结果，可以使用：
subscriber.receive(_) >>> ["ok", "error", "error", "ok"]
subscriber.receive(_) >> { throw new InternalError("ouch") }

而如果要每次调用都有不同的结果，可以把多次的返回连接起来：
subscriber.receive(_) >>> ["ok", "fail", "ok"] >> { throw new InternalError() } >> "ok"

4.5.mock and stubbing
如果既要判断某个mock对象的交互，又希望它返回值的话，可以结合mock和stub，可以这样：

then:
1 * subscriber.receive("message1") >> "ok"
1 * subscriber.receive("message2") >> "fail"
注意，spock不支持两次分别设定调用和返回值，如果把上例写成这样是错的：


setup:
subscriber.receive("message1") >> "ok"

when:
publisher.send("message1")

then:
1 * subscriber.receive("message1")

此时spock会对subscriber执行两次设定：

第一次设定receive(“message1”)只能调用一次，返回值为默认值（null）。
第二次设定receive(“message1”)会返回ok，不限制次数。


tips：
可以使用下划线（_）忽略不感兴趣的数据值
[a, b, _, c] << sql.rows("select * from maxdata")