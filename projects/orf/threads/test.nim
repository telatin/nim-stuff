import os, threadpool
from posix import signal, SIG_PIPE, SIG_IGN
signal(SIG_PIPE, SIG_IGN)

proc noise =
  for i in 0 ..< int(1e6):
    echo i

threadpool.spawn noise()
threadpool.spawn noise()
threadpool.sync()
