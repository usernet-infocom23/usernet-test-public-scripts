ssh usernet-vm3 rm tcp_stream*
for i in {1..20}
do
  echo start $i
  ssh usernet-vm3 ./neper/tcp_stream > result.neper/$i.txt &
#   sleep 1
  ssh usernet-vm4 ./neper/tcp_stream -c -H 172.16.1.103 -l 5 > /dev/null
  echo end $i
done
