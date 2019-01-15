## Spring Bean生命周期比较复杂，可以分为创建和销毁两个过程。

#### 首先，创建Bean会经过一系列的步骤，主要包括：
1. 实例化Bean对象。
2. 设置Bean属性。
3. 如果我们通过各种Aware接口声明了依赖关系，则会注入Bean对容器基础设施层面的依赖。具体包括BeanNameAware、BeanFactoryAware和ApplicationContextAware，分别会注入Bean ID、Bean Factory或者ApplicationContext。
4. 调用BeanPostProcessor的前置初始化方法postProcessBeforeInitialization。
5. 如果实现了InitializingBean接口，则会调用afterPropertiesSet方法。
6. 调用Bean自身定义的init方法。
7. 调用BeanPostProcessor的后置初始化方法postProcessAfterInitialization。
8. 创建过程完毕。

* 参考下面示意图理解这个具体过程和先后顺序。
[img](../../../static/img/SpringBean初始化流程.png)

#### 第二，Spring Bean的销毁过程会依次调用DisposableBean的destroy方法和Bean自身定制的destroy方法。
1. Spring Bean有五个作用域，其中最基础的有下面两种：
    1. Singleton，这是Spring的默认作用域，也就是为每个IOC容器创建唯一的一个Bean实例。
    2. Prototype，针对每个getBean请求，容器都会单独创建一个Bean实例。
2. 从Bean的特点来看，Prototype适合有状态的Bean，而Singleton则更适合无状态的情况。另外，使用Prototype作用域需要经过仔细思考，毕竟频繁创建和销毁Bean是有明显开销的。
3. 如果是Web容器，则支持另外三种作用域：
    1. Request，为每个HTTP请求创建单独的Bean实例。
    2. Session，很显然Bean实例的作用域是Session范围。
    3. GlobalSession，用于Portlet容器，因为每个Portlet有单独的Session，GlobalSession提供一个全局性的HTTP Session。

## 扩展
#### Spring的基础机制 -- 两个基本方面
1. 控制反转（Inversion of Control），或者也叫依赖注入（Dependency Injection），广泛应用于Spring框架之中，可以有效地改善了模块之间的紧耦合问题。
    * 从Bean创建过程可以看到，它的依赖关系都是由容器负责注入，具体实现方式包括带参数的构造函数、setter方法或者AutoWired方式实现
2. AOP，我们已经在前面接触过这种切面编程机制，Spring框架中的事务、安全、日志等功能都依赖于AOP技术

#### Spring到底是指什么
1. 前面谈到的Spring，其实是狭义的Spring Framework，其内部包含了依赖注入、事件机制等核心模块，也包括事务、O/R Mapping等功能组成的数据访问模块，以及Spring MVC等Web框架和其他基础组件。

2. 广义上的Spring已经成为了一个庞大的生态系统，例如：
    1. Spring Boot，通过整合通用实践，更加自动、智能的依赖管理等，Spring Boot提供了各种典型应用领域的快速开发基础，所以它是以应用为中心的一个框架集合。
    2. Spring Cloud，可以看作是在Spring Boot基础上发展出的更加高层次的框架，它提供了构建分布式系统的通用模式，包含服务发现和服务注册、分布式配置管理、负载均衡、分布式诊断等各种子系统，可以简化微服务系统的构建。
    3. 当然，还有针对特定领域的Spring Security、Spring Data等。

#### Spring AOP自身设计和实现的细节。
1. 我们为什么需要切面编程呢？
    1. 切面编程落实到软件工程其实是为了更好地模块化，而不仅仅是为了减少重复代码。通过AOP等机制，我们可以把横跨多个不同模块的代码抽离出来，让模块本身变得更加内聚，进而业务开发者可以更加专注于业务逻辑本身。从迭代能力上来看，我们可以通过切面的方式进行修改或者新增功能，这种能力不管是在问题诊断还是产品能力扩展中，都非常有用。
    2. AOP Proxy，它底层是基于JDK动态代理或者cglib字节码操纵等技术，运行时动态生成被调用类型的子类等，并实例化代理对象，实际的方法调用会被代理给相应的代理对象。但是，这并没有解释具体在AOP设计层面，什么是切面，如何定义切入点和切面行为呢？
2. Spring AOP引入了其他几个关键概念：
    1. Aspect，通常叫作方面，它是跨不同Java类层面的横切性逻辑。在实现形式上，既可以是XML文件中配置的普通类，也可以在类代码中用“@Aspect”注解去声明。在运行时，Spring框架会创建类似Advisor来指代它，其内部会包括切入的时机（Pointcut）和切入的动作（Advice）。
    2. Join Point，它是Aspect可以切入的特定点，在Spring里面只有方法可以作为Join Point。
    3. Advice，它定义了切面中能够采取的动作。如果你去看Spring源码，就会发现Advice、Join Point并没有定义在Spring自己的命名空间里，这是因为他们是源自AOP联盟，可以看作是Java工程师在AOP层面沟通的通用规范。
    4. Pointcut，它负责具体定义Aspect被应用在哪些Join Point，可以通过指定具体的类名和方法名来实现，或者也可以使用正则表达式来定义条件。  
    * Join Point仅仅是可利用的机会。
    * Pointcut是解决了切面编程中的Where问题，让程序可以知道哪些机会点可以应用某个切面动作。
    * 而Advice则是明确了切面编程中的What，也就是做什么；同时通过指定Before、After或者Around，定义了When，也就是什么时候做。

## 建议
1. 在准备面试时，如果在实践中使用过AOP是最好的，否则你可以选择一个典型的AOP实例，理解具体的实现语法细节，因为在面试考察中也许会问到这些技术细节。
2. 如果你有兴趣深入内部，最好可以结合Bean生命周期，理解Spring如何解析AOP相关的注解或者配置项，何时何地使用到动态代理等机制。为了避免被庞杂的源码弄晕，我建议你可以从比较精简的测试用例作为一个切入点，如CglibProxyTests。
3. 另外，Spring框架本身功能点非常多，AOP并不是它所支持的唯一切面技术，它只能利用动态代理进行运行时编织，而不能进行编译期的静态编织或者类加载期编织。例如，在Java平台上，我们可以使用Java Agent技术，在类加载过程中对字节码进行操纵，比如修改或者替换方法实现等。在Spring体系中，如何做到类似功能呢？你可以使用AspectJ，它具有更加全面的能力，当然使用也更加复杂。