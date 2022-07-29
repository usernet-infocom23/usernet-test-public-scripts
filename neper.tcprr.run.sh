ssh usernet-vm3 rm tcp_stream*
for i in {1..40}
do
  echo start $i
  ssh usernet-vm3 ./neper/tcp_rr > result.neper/$i.txt &
  sleep 1
  ssh usernet-vm4 ./neper/tcp_rr -c -H 172.16.1.103 -l 8 > /dev/null
  echo end $i
done
