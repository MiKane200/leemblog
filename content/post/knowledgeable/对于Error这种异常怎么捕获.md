# 父类Throwable

Throwable的两个子类Error和Exception

Exception的两个子类CheckedException和RuntimeException

二 发现问题

通常捕获异常catch的时候最大catch到Exception这个类就为止了，当然这能够处理大部分的异常情况。

但是值得注意的是，Exception不能捕捉到所有的异常。比如InvocationTargetException。

像这类 java.lang.NoClassDefFoundError: org/apache/commons/collections4/IterableUtils，由于NoClassDefFoundError是Throwable的Error子类，所以Exception是捕捉不到的

三 解决办法

catch(Throwable t) 
{ }

