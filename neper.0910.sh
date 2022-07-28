# start vm
echo 0. start vm
# ssh RDMA-09 'bash -l -c "virsh shutdown usernet-vm3"'
# ssh RDMA-10 'bash -l -c "virsh shutdown usernet-vm4"'
# ssh RDMA-09 'bash -l -c "virsh start usernet-vm3"'
# ssh RDMA-10 'bash -l -c "virsh start usernet-vm4"'
vm3=$(ssh RDMA-10 'bash -l -c "virsh list --all | grep ' usernet-vm3 '"' | awk '{ print $3}')
if [ "x$vm3" == "xrunning" ]
then
  ssh RDMA-10 'bash -l -c "virsh shutdown usernet-vm3"'
fi
vm3=$(ssh RDMA-09 'bash -l -c "virsh list --all | grep ' usernet-vm3 '"' | awk '{ print $3}')
if [ "x$vm3" == "xrunning" ]
then
  ssh RDMA-09 'bash -l -c "virsh shutdown usernet-vm3"'
fi
vm4=$(ssh RDMA-10 'bash -l -c "virsh list --all | grep ' usernet-vm4 '"' | awk '{ print $3}')
if [ "x$vm4" == "xrunning" ]
then
  ssh RDMA-10 'bash -l -c "virsh shutdown usernet-vm4"'
fi

sleep 5

ssh RDMA-09 'bash -l -c "virsh start usernet-vm3"'
ssh RDMA-10 'bash -l -c "virsh start usernet-vm4"'

sleep 10

# ssh RDMA-10 '
# cd usernet-module
# bash -l -c "./start-ivshmem-server.sh"
# '

# wait vm start
# sleep 10

# start netserver
echo 1. start neper run script
rm -rf result.neper && mkdir result.neper
wget https://github.com/usernet-infocom23/usernet-test-public-scripts/raw/main/neper.run.sh -O neper.run.sh
chmod +x neper.run.sh
bash -l -c './neper.run.sh' &
neperspid=$!

# sleep 25
echo 3. sleep 40s
sleep 50

# migration
echo 4. migration
ssh RDMA-09 -t 'bash -l -c "./usernet-module/virsh-migrate.sh usernet-vm3 RDMA-10"'
ssh RDMA-09 -t 'bash -l -c "./usernet-module/virsh-migrate.sh usernet-vm3 RDMA-10"'
ssh RDMA-09 -t 'bash -l -c "./usernet-module/virsh-migrate.sh usernet-vm3 RDMA-10"'

# attach
echo 5. attach ivshmem doorbell
ssh RDMA-10 '
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

# sleep 100
echo 7. sleep 100s
sleep 100
wait $neperspid

# recovery
echo 8. rollback
ssh usernet-vm3 'bash -l -c "sudo ./usernet-module/unload-intr-driver.sh"'
ssh usernet-vm4 'bash -l -c "sudo ./usernet-module/unload-intr-driver.sh"'
ssh RDMA-10 '
bash -l -c "./usernet-module/detach-ivshmem-doorbell.sh usernet-vm3"
bash -l -c "./usernet-module/detach-ivshmem-doorbell.sh usernet-vm4"
'

# extract csv from raw result
echo 10. extract csv from raw result
wget https://github.com/usernet-infocom23/usernet-test-public-scripts/raw/main/extract.neper.py -O extract.neper.py -q
python3 extract.neper.py result.neper > neper.result.csv

# plot chart
echo 11. plot chart
wget https://github.com/usernet-infocom23/usernet-test-public-scripts/raw/main/plot.neper.py -O plot.neper.py -q
python3 plot.neper.py neper.result.csv

# upload result to s3
echo 12. zip and upload result
rm -rf result && mkdir result
mv neper.png result/
rm result.zip
zip -r result.zip result
curl $(curl -s "https://bsakxn20uj.execute-api.us-east-1.amazonaws.com/default/usernet-paper-upload") --upload-file result.zip --header "X-Amz-ACL: public-read"

# shutdown vm
echo 14. shut down vm
ssh RDMA-10 '
bash -l -c "virsh shutdown usernet-vm3"
bash -l -c "virsh shutdown usernet-vm4"
cd usernet-module
bash -l -c "./stop-ivshmem-server.sh"
'

# wait for vm shutdown
# sleep 10
