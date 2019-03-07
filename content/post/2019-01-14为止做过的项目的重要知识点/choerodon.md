## 安全管理控制 -- Shiro
1. 通过自定义的Realm继承AuthorizingRealm来实现对用户密码认证和用户权限校验
2. 设置过滤器来拦截一些需要权限访问页面的请求，比如登录
3. 在实际开发中，url和对应的访问权限可能需要从数据库中读取，我们可以定义一个工具类从数据库中读取访问权限并传递给Shiro。
4. 通过在web.xml中配置shiro的filter
5. 通过在applicationContext.xml中
    1. 配置anon: 例子/admins/**=anon 没有参数，表示可以匿名使用。
    2. authc: 例如/admins/user/**=authc表示需要认证(登录)才能使用，没有参数
    3. roles(角色)：例子/admins/user/**=roles[admin]
    4. perms（权限）：例子/admins/user/**=perms[add]
    5. authcBasic： 例如/admins/user/**=authcBasic没有参数.表示httpBasic认证
    6. ssl: 例子/admins/user/**=ssl没有参数，表示安全的url请求，协议为https
    7. user: 例如/admins/user/**=user没有参数表示必须存在用户，当登入操作时不做检查