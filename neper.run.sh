ssh usernet-vm3 rm tcp_stream*
for i in {1..40}
do
  echo start $i
  ssh usernet-vm3 sudo LIBUSERNET_IVSHMEM_MEMDEV_PATH="/sys/bus/pci/devices/0000:07:00.0/resource2_wc" LD_PRELOAD="./libusernet.dummy.so" ./neper/tcp_stream > result.neper/$i.txt &
  sleep 1
  ssh usernet-vm4 sudo LIBUSERNET_IVSHMEM_MEMDEV_PATH="/sys/bus/pci/devices/0000:07:00.0/resource2_wc" LD_PRELOAD="./libusernet.dummy.so" ./neper/tcp_stream -c -H 172.16.1.103 -l 8 -F 8 -T 4 > /dev/null
  echo end $i
done
