# timed-rs (time daemon rs)

It's a implementation of "TCP Based Time Service" [Time Protocol [RFC868]](https://datatracker.ietf.org/doc/html/rfc868).


## Examples

### Server

```
./timed-rs # default port usage (0.0.0.0:37)
./timed-rs 0.0.0.0:3737 # specific port usage
```

NOTE: 37 is a well-known port. It may require administrative permission.

### Client

```
$ nc 127.0.0.1 37 | xxd
00000000: e8f7 1e9a                                ....
$ rdate 127.0.0.1
rdate: [127.0.0.1]	Thu Nov  9 18:02:18 2023
4
```
