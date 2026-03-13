#!/bin/bash

exec unshare -n bash -c '
ip link set lo up
nft -f -<<EOF
table t {
	chain c {
		ct state new accept
	}
}
EOF

timeout 20 ./test_filter | grep -q NEW &
rp=$!
sleep 1

for i in $(seq 1 127); do
	timeout 1 ping -q -c 1 -I 127.0.0.$i 127.0.0.$i
done > /dev/null

wait $rp
ret=$?

echo "test_filter: return $ret"

exit $ret
'
