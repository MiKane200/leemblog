# leemblog

This is a blog site base on hugo server.

To run this blog,u need to have installed install docker and have access to a Linux or MacOSX system (case-sensitive filesystem required).

There are some steps for you to run the blog site:
(before you run this blog site,you have to ensure your machine's 1313 port is not occupied).
1. Download files from https://github.com/MiKane200/leemblog.git or `git clone -- recursive git@github.com:MiKane200/leemblog.git` by git.
    tips：If you are not sure the themes are downloaded  completely,try `git submodule update --init --recursive`.
2. open your docker.
3. Run `sh build.sh`.
4. Run `sh run.sh`.
5. Open you browser and type http://localhost:1313/ or your machine ip.such as http://192.168.99.100:1313/. 
how to find my IP? [^!ClickHere]
6. enter username'lee'and password'c7nc7n'.


##### tips:
* you may need to restart or stop this blog,try `sh restart.sh` or `sh stop .sh`.
[^!ClickHere]: After enter your docker,running `docker-machine env` + your manchine name,you will find DOCKER_HOST and you will get your IP address.


Sunshine!
<p align="right">leemblog By zongwei Li</p>