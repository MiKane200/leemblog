# 比较常用的是mysql 数据库引擎 MyISAM和InnoDB

## 构成上的区别： 

##### MyISAM
1. 每个MyISAM在磁盘上存储成三个文件。第一个文件的名字以表的名字开始，扩展名指出文件类型。
2. .frm文件存储表定义。
3. 数据文件的扩展名为.MYD (MYData)。
4. 索引文件的扩展名是.MYI (MYIndex)。

##### InnoDB
基于磁盘的资源是InnoDB表空间数据文件和它的日志文件，InnoDB 表的大小只受限于操作系统文件的大小，一般为 2GB
  

## 事务处理上方面 : 

##### MyISAM
强调的是性能，其执行数度比InnoDB类型更快，但是不提供事务支持

#####  InnoDB
提供事务支持事务，外部键（foreign key）等高级数据库功能
  

##  SELECT   UPDATE,INSERT ， Delete 操作 

##### MyISAM：
如果执行大量的SELECT，MyISAM是更好的选择

##### InnoDB
1. 如果你的数据执行大量的INSERT 或 UPDATE，出于性能方面的考虑，应该使用InnoDB表
2. DELETE   FROM table时，InnoDB不会重新建立表，而是一行一行的删除。
3. LOAD   TABLE FROM MASTER操作对InnoDB是不起作用的，解决方法是首先把InnoDB表改成MyISAM表，导入数据后再改成InnoDB表，但是对于使用的额外的InnoDB特性（例如外键）的表不适用


## 表的具体行数 
##### MYISAM
select count(*) from table,MyISAM只要简单的读出保存好的行数，注意的是，当count(*)语句包含   where条件时，两种表的操作是一样的

##### InnoDB 
不保存表的具体行数，也就是说，执行select count(*) from table时，InnoDB要扫描一遍整个表来计算有多少行

  
## 锁 

##### MYISAM表
锁

##### InnoDB
提供行锁(locking on row level)，提供与 Oracle 类型一致的不加锁读取(non-locking read in SELECTs)，另外，InnoDB表的行锁也不是绝对的，如果在执行一个SQL语句时MySQL不能确定要扫描的范围，InnoDB表同样会锁全表， 例如update table set num=1 where name like “%aaa%”
