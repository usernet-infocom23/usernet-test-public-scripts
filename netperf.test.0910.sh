echo 0. demigration
ssh RDMA-09 -t 'bash -l -c "./usernet-module/virsh-migrate.sh usernet-vm4 RDMA-10"'

# start netserver
echo 1. start netserver
ssh usernet-vm3 "
sudo killall netserver
netserver -p 8864
"

sleep 1

# start netperf
echo 2. start netperf
ssh usernet-vm4 "netperf -H 172.16.1.103 -p 8864 -D 1 -l 100 -P 0 > netperf.result.txt" &

# sleep 50
echo 3. sleep 50s
sleep 50

# migration
echo 4. migration
ssh RDMA-10 -t 'bash -l -c "./usernet-module/virsh-migrate.sh usernet-vm4 RDMA-09"'

# attach
echo 5. attach ivshmem doorbell
ssh RDMA-09 '
bash -l -c "./start-ivshmem-server.sh"
bash -l -c "./usernet-module/attach-ivshmem-doorbell.sh usernet-vm3"
bash -l -c "./usernet-module/attach-ivshmem-doorbell.sh usernet-vm4"
'

# modprobe & insmod
echo 6. insert intr driver
ssh usernet-vm3 'bash -l -c "sudo ./usernet-module/load-intr-driver.sh"'
ssh usernet-vm4 'bash -l -c "sudo ./usernet-module/load-intr-driver.sh"'
# test ivshmem getpeerid is valid on vm
echo 6.1. test getpeerid
ssh usernet-vm3 'sudo ./usernet-module/ivshmem-getpeerid'
ssh usernet-vm4 'sudo ./usernet-module/ivshmem-getpeerid'

# sleep 50
echo 7. sleep 50s
sleep 50

# recovery
echo 8. rollback
ssh usernet-vm3 'bash -l -c "sudo ./usernet-module/unload-intr-driver.sh"'
ssh usernet-vm4 'bash -l -c "sudo ./usernet-module/unload-intr-driver.sh"'
ssh RDMA-09 '
bash -l -c "./usernet-module/detach-ivshmem-doorbell.sh usernet-vm3"
bash -l -c "./usernet-module/detach-ivshmem-doorbell.sh usernet-vm4"
# bash -l -c "./stop-ivshmem-server.sh"
'

# copy result from vm
echo 9. copy result from vm
scp usernet-vm4:netperf.result.txt netperf.result.txt
