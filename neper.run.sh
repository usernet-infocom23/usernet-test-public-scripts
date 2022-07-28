for i in {1..20}
do
  ssh usernet-vm3 ./neper/tcp_stream > result/$i.txt &
  sleep 1
  ssh usernet-vm4 ./neper/tcp_stream -c -H 172.16.1.103 -l 5 > /dev/null
  echo $i
done
