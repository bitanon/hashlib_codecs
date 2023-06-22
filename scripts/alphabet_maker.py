#!/usr/bin/env python3


def show(list, n):
    cc = 0
    for x in list:
        if cc % n == 0:
            print("\n  ", end="")
        print(x, end=", ")
        cc += 1
    print()
    print()


def rev(*merge):
    v = []
    for s in merge:
        for i, c in enumerate(s):
            while c >= len(v):
                v += [-1 for _ in range(19)]
            v[c] = i
    show(["__" if x < 0 else "%02d" % x for x in v], 19)


def fwd(s):
    show([hex(x) for x in s], 8)


# print("base32hex", end=":")
# fwd(b"0123456789ABCDEFGHIJKLMNOPQRSTUV")
# print("base32hex lowercase", end=":")
# fwd(b"0123456789abcdefghijklmnopqrstuv")
# print("base32hex reversed", end=":")
# rev(b"0123456789ABCDEFGHIJKLMNOPQRSTUV", b"0123456789abcdefghijklmnopqrstuv")

# print("crockford", end=":")
# fwd(b"0123456789ABCDEFGHJKMNPQRSTVWXYZ")
# print("crockford reversed", end=":")
# rev(b"0123456789ABCDEFGHJKMNPQRSTVWXYZ")

# print("geohash", end=":")
# fwd(b"0123456789bcdefghjkmnpqrstuvwxyz")
# print("geohash reversed", end=":")
# rev(b"0123456789bcdefghjkmnpqrstuvwxyz")

# print("z-base-32", end=":")
# fwd(b"ybndrfg8ejkmcpqxot1uwisza345h769")
# print("z-base-32 reversed", end=":")
# rev(b"ybndrfg8ejkmcpqxot1uwisza345h769")

print("word-safe", end=":")
fwd(b"23456789CFGHJMPQRVWXcfghjmpqrvwx")
print("word-safe reversed", end=":")
rev(b"23456789CFGHJMPQRVWXcfghjmpqrvwx")
