## 这两者的施加者是有本质区别的. 
1. sleep()是让某个线程暂停运行一段时间,其控制范围是由当前线程决定,也就是说,在线程里面决定.
2. wait(),是由某个确定的对象来调用的

* 两者都可以让线程暂停一段时间,但是本质的区别是一个线程的运行状态控制,一个是线程之间的通讯的问题

 在java.lang.Thread类中，提供了sleep()，
而java.lang.Object类中提供了wait()， notify()和notifyAll()方法来操作线程
sleep()可以将一个线程睡眠，参数可以指定一个时间。
而wait()可以将一个线程挂起，直到超时或者该线程被唤醒。
    wait有两种形式wait()和wait(milliseconds).
sleep和wait的区别有：
  1，这两个方法来自不同的类分别是Thread和Object
  2，最主要是sleep方法没有释放锁，而wait方法释放了锁，使得其他线程可以使用同步控制块或者方法。
  3，wait，notify和notifyAll只能在同步控制方法或者同步控制块里面使用，而sleep可以在
    任何地方使用
   synchronized(x){
      x.notify()
     //或者wait()
   }
   4,sleep必须捕获异常，而wait，notify和notifyAll不需要捕获异常