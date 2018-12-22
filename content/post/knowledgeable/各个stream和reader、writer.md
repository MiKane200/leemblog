Input、outputStream: 用来处理 （一字节）8bit 字节流 只有电脑看得懂的东西 不会更改任何信息
reader、writer: 用来处理 （char一字符）16bit 字符流 转换给人看得懂的东西 在操作时会进行decode/encode. 它会根据你的系统属性file.encoding来decode数据
Input、outputstreamReader、Writer: 以上stream到reader、writer的适配器


InputStream：得到的是字节输入流，InputStream.read(“filename”)之后，得到字节流

Reader:读取的是字符流 
InputStreamReader:从字节到字符的桥梁

InputStreamReader(InputStream.read(“filename”));

reader.read(InputStreamReader(InputStream in));便可从字节变为字符，打印显示了。

Java.io.Reader 和 java.io.InputStream 组成了Java 输入类。 
Reader 用于读入16位字符，也就是Unicode 编码的字符；而 InputStream 用于读入 ASCII 字符和二进制数据。 
Reader支持16位的Unicode字符输出， 
InputStream支持8位的字符输出。 
Reader和InputStream分别是I/O库提供的两套平行独立的等级机构，

1byte = 8bits 
InputStream、OutputStream是用来处理8位元的流， 
Reader、Writer是用来处理16位元的流。

而在JAVA语言中，byte类型是8位的，char类型是16位的，所以在处理中文的时候需要用Reader和Writer。

值得说明的是，在这两种等级机构下，还有一道桥梁 
InputStreamReader、OutputStreamWriter负责进行InputStream到Reader的适配和由OutputStream到Writer的适配。

在 Java中，有不同类型的 Reader 输入流对应于不同的数据源： 
FileReader 用于从文件输入； CharArrayReader 用于从程序中的字符数组输入； StringReader 用于从程序中的字符串输入； PipedReader 用于读取从另一个线程中的 PipedWriter 写入管道的数据。

相应的也有不同类型的 InputStream 输入流对应于不同的数据源：FileInputStream，ByteArrayInputStream，StringBufferInputStream，PipedInputStream。

另外，还有两种没有对应 Reader 类型的 InputStream 输入流： Socket 用于套接字； URLConnection 用于 URL 连接。 这两个类使用 getInputStream() 来读取数据。 
相应的，java.io.Writer 和 java.io.OutputStream 也有类似的区别。