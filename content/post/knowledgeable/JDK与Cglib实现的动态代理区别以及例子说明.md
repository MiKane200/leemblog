1. @Transactional与@Async
Async强制覆盖了aop的order为Integer.MIN_VALUE（spring认为Async应该是aop链中的第一个advisor，参考https://jira.spring.io/browse/SPR-7147），而且order不可配置；Transactional没有覆盖，仍然为默认的Integer.MAX_VALUE，order可配置。所以异步切面会先于事务切面执行。

(如果是相反的情况，事务切面先于Async切面执行，由于spring事务管理重度依赖ThreadLocal，所以异步线程里面感知不到事务，导致Async注解和Transactional注解同时使用时，Transactional注解会失效。具体原因是：在Spring开启事务之后，设置Connection到当前线程，然后立马开启一个新线程，mybatis执行实际的SQL代码时，通过ThreadLocal获取不到Connection，开启新的Connection，也不会设置autoCommit，那么这个函数整体将没有事务。)

2. JDK中使用 实现了InvocationHandler接口的方式来进行动态代理，而cglib则使用 实现了 MethodInterceptor 接口的方式来进行动态代理。但是，JDK的动态代理依靠接口实现，如果有些类并没有实现接口，则不能使用JDK代理， 这就要使用cglib动态代理了。cglib是针对类来实现代理的，他的原理是对指定的目标类生成一个子类， 并覆盖其中方法实现增强，但因为采用的是继承，所以不能对final修饰的类进行代理。因此，总的来说，用cglib会更好点。

spring源码 判断使用jdk还是cglib代理：
    public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
        if (!config.isOptimize() && !config.isProxyTargetClass() && !this.hasNoUserSuppliedProxyInterfaces(config)) {
            return new JdkDynamicAopProxy(config);
        } else {
            Class<?> targetClass = config.getTargetClass();
            if (targetClass == null) {
                throw new AopConfigException("TargetSource cannot determine target class: Either an interface or a target is required for proxy creation.");
            } else {
                return (AopProxy)(!targetClass.isInterface() && !Proxy.isProxyClass(targetClass) ? new ObjenesisCglibAopProxy(config) : new JdkDynamicAopProxy(config));
            }
        }
    }


    config.isOptimize()config.isProxyTargetClass()默认返回都是false，所以在默认情况下目标对象有没有实现接口决定着Spring采取的策略，当然可以设置config.isOptimize()或者config.isProxyTargetClass()返回为true，这样无论目标对象有没有实现接口Spring都会选择使用CGLIB代理。


```java
package com.ffcs.icity.proxy.jdk;
 
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
 
/**
 * JDK动态代理代理类
 *1. 获取 RealSubject上的所有接口列表； 
 *2. 确定要生成的代理类的类名； 
 *3. 根据需要实现的接口信息，在代码中动态创建该Proxy类的字节码； 
 *4. 将对应的字节码转换为对应的class 对象； 
 *5. 创建InvocationHandler 实例handler，用来处理Proxy所有方法调用； 
 *6. Proxy 的class对象 以创建的handler对象为参数，实例化一个proxy对象
 */ 
public class BusiProxy implements InvocationHandler{
 
	private Object target;  
	
    /** 
     * 绑定委托对象并返回一个代理类 
     * @param target 
     * @return 
     */  
    public Object bind(Object target) {
        this.target = target;  
        //取得代理对象  
        return Proxy.newProxyInstance(target.getClass().getClassLoader(),  
                target.getClass().getInterfaces(), this);   //要绑定接口(这是一个缺陷，cglib弥补了这一缺陷)  
    }  
  
    @Override  
    /** 
     * 调用方法 
     */  
    public Object invoke(Object proxy, Method method, Object[] args)  
            throws Throwable {  
        Object result=null;  
        System.out.println("事物开始");  
        //执行方法  
        result=method.invoke(target, args);  
        System.out.println("事物结束");  
        return result;  
    }  
}

package com.ffcs.icity.proxy.jdk;
/**
 * 但是，JDK的动态代理依靠接口实现，如果有些类并没有实现接口，则不能使用JDK代理，
 * 这就要使用cglib动态代理了。
 *
 */
public class TestProxy {
 
	public static void main(String[] args) {
		
		BusiProxy t = new BusiProxy();
		IBusi busi = (IBusi)t.bind(new BusiImpl());
		busi.test();
	}
	
}
```

```java

package com.ffcs.icity.proxy.cglib;
 
import java.lang.reflect.Method;
 
import net.sf.cglib.proxy.Enhancer;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;
 
/**
 * 使用cglib进行动态代理工作
 *
 */
public class CglibBusiProxy implements MethodInterceptor {
 
	private Object target;
 
	/** 
	 * 创建代理对象 
	 *  
	 * @param target 
	 * @return 
	 */
	public Object getInstance(Object target) {
		this.target = target;
		Enhancer enhancer = new Enhancer();
		enhancer.setSuperclass(this.target.getClass());
		// 回调方法  
		enhancer.setCallback(this);
		// 创建代理对象  
		return enhancer.create();
	}
 
	@Override
	// 回调方法  
	public Object intercept(Object obj, Method method, Object[] args,
			MethodProxy proxy) throws Throwable {
		System.out.println("事物开始");
		proxy.invokeSuper(obj, args);
		System.out.println("事物结束");
		return null;
 
	}
 
}

TestCglibProxy.java
package com.ffcs.icity.proxy.cglib;
 
 
/**
 * cglib是针对类来实现代理的，他的原理是对指定的目标类生成一个子类，
 * 并覆盖其中方法实现增强，但因为采用的是继承，所以不能对final修饰的类进行代理。 
 *
 */
public class TestCglibProxy {
 
	public static void main(String[] args) {
		
		CglibBusiProxy cglibProxy = new CglibBusiProxy();
		ICgligBusi busi = (ICgligBusi)cglibProxy.getInstance(new CglibBusiImpl()); 
		busi.test();
	}
	
}
```