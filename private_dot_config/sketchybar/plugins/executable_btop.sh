#!/bin/bash
# Apple logo: opens btop in a Terminal window, or quits it if it's already
# running. SIGINT is btop's clean quit, so Terminal closes the
# window as it would after pressing q.

if pgrep -xq btop; then
  pkill -INT -x btop
else
  open -a Terminal /opt/homebrew/bin/btop
fi
