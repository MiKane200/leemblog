## 使用到的一些设计模式
#### 门面设计模式（有很多实现如request的封装，实现对数据的隔离）
#### 观察者模式（如lifecycle，sevlet实例的创建，session管理，container）
#### 命令设计模式（connector（请求者）和container（接受者）Httpprocess（命令））
#### 责任链设计模式（从engine-host-context-wrapper，这里与平常责任链不同的是使用到了valve和pipline（能使得向下传递的过程中能接受到外界的干预，每一段pipline管子最后总有一个节点保证它一定能流到下一个子容器中，所以每一个容器都有一个standardXXXvalve，valve小口子）