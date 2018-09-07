## 使用CookieVlaue标签来获取指定name的Cookie
```java
//   使用HttpServletRequest 获取cookie
@RequestMapping(value = "/ping", method = RequestMethod.GET)
public Response ping(@CookieValue("test") String fooCookie) throws IOException {
    //Mice
    return new Response().setData("OK, cookieValue=!!!" + fooCookie);
}
    //在上面的的代码中如果CooKie不存在，会抛出返回异常：

/**
*{
  "timestamp": 1466584427218,
  "status": 400,
  "error": "Bad Request",
  "exception": "org.springframework.web.bind.ServletRequestBindingException",
  "message": "Missing cookie 'majun' for method parameter of type String",
  "path": "/register/test/service/ping"
}
*/
//可以通过设置默认值来解决这个异常，如果业务上不呈现这个异常的话！!
```

## 使用HttpServletResponse， Cookie类，增加cookie
```java
//   使用HttpServletResponse增加cookie, cookie会返回给前端
@RequestMapping(value = "/getCookie", method = RequestMethod.GET)
public Response getCookie(HttpServletResponse httpServletResponse) throws IOException {
    Cookie cookie = new Cookie("majun", "xiaoya");
    cookie.setMaxAge(10); //设置cookie的过期时间是10s
    httpServletResponse.addCookie();
    return new Response().setData("allocate cookie success!!!");
}
//如果创建的Cookie (name相同)已经存在，那么新的Cookie会覆盖老的cookie。
```

## 