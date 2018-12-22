##元注解
注解	说明
@Target	定义注解的作用目标

@Retention	定义注解的保留策略。RetentionPolicy.SOURCE:注解仅存在于源码中，在class字节码文件中不包含；
    RetentionPolicy.CLASS:默认的保留策略，注解会在class字节码文件中存在，但运行时无法获得;RetentionPolicy.RUNTIME:注解会在class字节码文件中存在，在运行时可以通过反射获取到。

@Document	说明该注解将被包含在javadoc中

@Inherited	说明子类可以继承父类中的该注解
---------------------

## Target类型说明

ElementType.TYPE	接口、类、枚举、注解
ElementType.FIELD	字段、枚举的常量
ElementType.METHOD	方法
ElementType.PARAMETER	方法参数
ElementType.CONSTRUCTOR	构造函数
ElementType.LOCAL_VARIABLE	局部变量
ElementType.ANNOTATION_TYPE	注解
ElementType.PACKAGE	包
--------------------- 

## 实现
1. 如：extends AbstractProcessor
然后：
```java
@SupportedAnnotationTypes("*")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class NameScannerProcessor extends AbstractProcessor{
@Override
    public void init(ProcessingEnvironment processingEnv){
        super.init(processingEnv);
    }

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv){
        if(!roundEnv.processingOver()){
            for(Element element : roundEnv.getElementsAnnotatedWith(NameScanner.class)){
                String name = element.getSimpleName().toString();
                processingEnv.getMessager().printMessage(Diagnostic.Kind.NOTE, "element name: " + name);
            }
        }
        return false;
    }
```
2. 在init()中我们获得如下引用：
    1. Elements：一个用来处理Element的工具类
    2. Types：一个用来处理TypeMirror的工具类
    3. Filer：正如这个名字所示，使用Filer你可以创建文件