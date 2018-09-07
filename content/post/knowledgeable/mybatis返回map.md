## Mybatis select返回值为map时,选取表字段的两列作为key,value
```xml
<resultMap id="getAllSetDaysResult"   type="HashMap">
	<result property="key" column="SP_FPARAMEKEY" />
	<result property="value" column="SP_FPARAMEVALUE" />
</resultMap>

<select id="getAllSetDays" resultMap="getAllSetDaysResult">
SELECT SP.FPARAMEKEY SP_FPARAMEKEY, SP.FPARAMEVALUE SP_FPARAMEVALUE 
  FROM T_SERVER_PARAMETER SP
 WHERE SP.FPARAMEKEY IN ('XXX')
</select>
```