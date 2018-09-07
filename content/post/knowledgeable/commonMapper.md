## Select
1. 
方法：List<T> select(T record);
说明：根据实体中的属性值进行查询，查询条件使用等号
2. 
方法：T selectByPrimaryKey(Object key);
说明：根据主键字段进行查询，方法参数必须包含完整的主键属性，查询条件使用等号
3. 
方法：List<T> selectAll();
说明：查询全部结果，select(null)方法能达到同样的效果
4. 
方法：T selectOne(T record);
说明：根据实体中的属性进行查询，只能有一个返回值，有多个结果是抛出异常，查询条件使用等号
5. 
方法：int selectCount(T record);
说明：根据实体中的属性查询总数，查询条件使用等号

## Insert
1. 
方法：int insert(T record);
说明：保存一个实体，null的属性也会保存，不会使用数据库默认值
2. 
方法：int insertSelective(T record);
说明：保存一个实体，null的属性不会保存，会使用数据库默认值

## Update
1. 
方法：int updateByPrimaryKey(T record);
说明：根据主键更新实体全部字段，null值会被更新
2. 
方法：int updateByPrimaryKeySelective(T record);
说明：根据主键更新属性不为null的值

## Delete
1. 
方法：int delete(T record);
说明：根据实体属性作为条件进行删除，查询条件使用等号
2. 
方法：int deleteByPrimaryKey(Object key);
说明：根据主键字段进行删除，方法参数必须包含完整的主键属性