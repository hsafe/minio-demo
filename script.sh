#!/bin/bash

##Prepared by Hsafe for a minio security presentaion. It tries to automatically shows how you may create user specific access policies to specific buckets with various access levels.
##Note that minio already have few access_policies builtin which are not the case for this demo.

## This demo presume you already are running a minio service/docker on localhost and it is reachable via http://localhost:9000&&9001 for this demo.Note that the default admin uname/pass used.
## Also please note that you need to have a sort of minio_client(mc) binary available for this demo in your path.

RED='\033[0;31m'
BOLD=$(tput bold)
NORM=$(tput sgr0)

{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}set the mc access to the local minio service ${NORM}"
sleep 7
{ set -x; } &> /dev/null
mc alias set local http://localhost:9000 minioadmin minioadmin
{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}check if the super user access will work ${NORM}"
sleep 7
{ set -x; } &> /dev/null
mc ls local
{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}create 3 seperate buckets that will be accessible later by three assigned users only ${NORM}"
sleep 10
{ set -x; } &> /dev/null
mc mb local/demo1
mc mb local/demo2
mc mb local/demo3

{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}Assign a quota of 1GB to each of the buckets for size-restriction policy ${NORM}"
sleep 10
{ set -x; } &> /dev/null
 mc quota set local/demo1 --size 1GB
 mc quota set local/demo2 --size 1GB
 mc quota set local/demo3 --size 1GB

{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}check existing policies ${NORM}"
sleep 5
{ set -x; } &> /dev/null
mc admin policy list local

{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}check the existing users ${NORM}"
sleep 5
{ set -x; } &> /dev/null
mc admin user list local

{ set +x; } &> /dev/null
sleep 5
#mc anonymous get public local/demo

echo -e "${RED}${BOLD}create 3 different user profiles in minio, these users will later be bound to three differnet policies which restrict them to their specific buckets ${NORM}"
sleep 15

{ set -x; } &> /dev/null
mc admin user add local demo1 demo1@12345
mc admin user add local demo2 demo2@12345
mc admin user add local demo3 demo3@12345

{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}check the three locally composed policies which need to be uploaded to the minio IDP  ${NORM}"
sleep 10

{ set -x; } &> /dev/null
cat ./demo1-readWriteDelete.policy
sleep 5
cat ./demo2-readWriteDelete.policy
sleep 5
cat ./demo3-readWriteDelete.policy
sleep 5

{ set +x; } &> /dev/null

echo -e "${RED}${BOLD}Upload and assign each policies to the newly created profiles and evenually to their right bucket ${NORM}"
sleep 10

{ set -x; } &> /dev/null
mc admin policy create local demo1_policy demo1-readWriteDelete.policy
sleep 2
mc admin policy attach local demo1_policy --user demo1
sleep 2
mc admin policy create local demo2_policy demo2-readWriteDelete.policy
sleep 2
mc admin policy attach local demo2_policy --user demo2
sleep 2
mc admin policy create local demo3_policy demo3-readWriteDelete.policy
sleep 2
mc admin policy attach local demo3_policy --user demo3
sleep 2

{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}Check the list of the users and their policies assigned ${NORM}"
sleep 10
{ set -x; } &> /dev/null

mc admin user list local

{ set +x; } &> /dev/null

echo -e "${RED}${BOLD}Create three different minio_client profiles based on the three credentials to test everything in their own sandbox ${NORM}"
sleep 10
{ set -x; } &> /dev/null

mc alias set local_demo1 http://localhost:9000 demo1 demo1@12345
sleep 2
mc alias set local_demo2 http://localhost:9000 demo2 demo2@12345
sleep 2
mc alias set local_demo3 http://localhost:9000 demo3 demo3@12345
sleep 2


{ set +x; } &> /dev/null

echo -e "${RED}${BOLD}check the access policies applied to each users ${NORM}"
sleep 10

{ set -x; } &> /dev/null
mc admin policy info local consoleAdmin 
sleep 5
mc admin policy info local demo1_policy
sleep 5
mc admin policy info local demo2_policy
sleep 5
mc admin policy info local demo3_policy
sleep 5

{ set +x; } &> /dev/null

echo -e "${RED}${BOLD}check the different profiles accessing the minio server and their sandbox view ${NORM}"
sleep 10

{ set -x; } &> /dev/null

cat ~/.mc/config.json |grep -A3 demo1
{ set +x; } &> /dev/null
sleep 2
{ set -x; } &> /dev/null
cat ~/.mc/config.json |grep -A3 demo2
{ set +x; } &> /dev/null
sleep 2
{ set -x; } &> /dev/null
cat ~/.mc/config.json |grep -A3 demo3
{ set +x; } &> /dev/null
sleep 2

{ set +x; } &> /dev/null

echo -e "${RED}${BOLD}final test and where all come together showing the different access levels and how the minio-server sandboxes the different users ${NORM}"
sleep 10
{ set -x; } &> /dev/null
mc ls local
{ set +x; } &> /dev/null
sleep 5
{ set -x; } &> /dev/null
mc ls local_demo1
{ set +x; } &> /dev/null
sleep 5
{ set -x; } &> /dev/null
mc ls local_demo2
{ set +x; } &> /dev/null
sleep 5
{ set -x; } &> /dev/null
mc ls local_demo3
{ set +x; } &> /dev/null
echo -e "${RED}${BOLD}local_demoX is bound to demoX users each and hence the env/users/their namespaces are all sand-boxed to themselves ${NORM}"
echo -e "${RED}${BOLD}end of the demo... thanks ${NORM}"