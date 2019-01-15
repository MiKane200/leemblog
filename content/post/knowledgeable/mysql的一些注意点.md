## having和where
上面的having可以用的前提是我已经筛选出了goods_price字段，在这种情况下和where的效果是等效的，但是如果我没有select goods_price 就会报错！！因为having是从前筛选的字段再筛选，而where是从数据表中的字段直接进行的筛选的。

## mysql执行顺序
1. from 
(3 join 
(2) on 
(4) where 
(5)group by(开始使用select中的别名，后面的语句中都可以使用)
(6) avg,sum.... 
(7)having 
(8) select 
(9) distinct 
(10) order by 