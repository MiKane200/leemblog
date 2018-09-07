1. CMD
使用 service nginx start 命令，则是希望 upstart 来以后台守护进程形式启动 nginx 服
务。而刚才说了 CMD service nginx start 会被理解为 CMD [ "sh", "-c", "service nginx
start"] ，因此主进程实际上是 sh 。那么当 service nginx start 命令结束后， sh 也就结
束了， sh 作为主进程退出了，自然就会令容器退出。
正确的做法是直接执行 nginx 可执行文件，并且要求以前台形式运行。比如：
CMD ["nginx" "-g" "daemon off;"]
