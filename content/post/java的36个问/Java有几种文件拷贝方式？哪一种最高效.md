## 回答
1. 利用java.io类库，直接为源文件构建一个FileInputStream读取，然后再为目标文件构建一个FileOutputStream，完成写入工作。
2. 利用java.nio类库提供的transferTo或transferFrom方法实现。
3. Java标准类库本身已经提供了几种Files.copy的实现。对于Copy的效率，这个其实与操作系统和配置等情况相关，总体上来说，NIO transferTo/From的方式可能更快，因为它更能利用现代操作系统底层机制，避免不必要拷贝和上下文切换。

## 从技术角度展开，下面这些方面值得注意：
1. 不同的copy方式，底层机制有什么区别？
2. 为什么零拷贝（zero-copy）可能有性能优势？
3. Buffer分类与使用。
4. Direct Buffer对垃圾收集等方面的影响与实践选择。

## Buffer有几个基本属性：
1. capcity，它反映这个Buffer到底有多大，也就是数组的长度。
2. position，要操作的数据起始位置。
3. limit，相当于操作的限额。在读取或者写入时，limit的意义很明显是不一样的。比如，读取操作时，很可能将limit设置到所容纳数据的上限；而在写入时，则会设置容量或容量以下的可写限度。
4. mark，记录上一次postion的位置，默认是0，算是一个便利性的考虑，往往不是必须的。

#### 前面三个是我们日常使用最频繁的，简单梳理下Buffer的基本操作：
1. 我们创建了一个ByteBuffer，准备放入数据，capcity当然就是缓冲区大小，而position就是0，limit默认就是capcity的大小。
2. 当我们写入几个字节的数据时，position就会跟着水涨船高，但是它不可能超过limit的大小。
3. 如果我们想把前面写入的数据读出来，需要调用flip方法，将position设置为0，limit设置为以前的position那里。
4. 如果还想从头再读一遍，可以调用rewind，让limit不变，position再次设置为0。

## 如果我们需要在channel读取的过程中，将不同片段写入到相应的Buffer里面（类似二进制消息分拆成消息头、消息体等），可以采用NIO的什么机制做到呢？
可以利用NIO分散-scatter机制来写入不同buffer。
Code:
ByteBuffer header = ByteBuffer.allocate(128);
ByteBuffer body   = ByteBuffer.allocate(1024);
ByteBuffer[] bufferArray = {header, body};
channel.read(bufferArray);
注意:该方法适用于请求头长度固定。