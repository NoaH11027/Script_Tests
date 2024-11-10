#!/bin/bash
set -Eeuo pipefail

trap "echo ERR trap fired!" ERR

myfunc()
{
  # 'foo' is a non-existing command
  foo
}

myfunc
echo "bar"

# output
# ------
# line 9: foo: command not found
# ERR trap fired!
#
# Not only do we still have an immediate exit, we can also clearly see that the
# ERR trap was actually fired now.
