- 1

```c
适用于jz2440
```

- 更改文件编码
```c
main.c: C source, ISO-8859 text, with CRLF line terminators
dos2unix main.c
main.c: C source, ISO-8859 text ## 当前为乱码且格式仍没有变化
iconv -f 'gbk' -t 'utf-8' main.c > main.c_bak && mv main.c_bak main.c
main.c: C source, UTF-8 Unicode text
```
