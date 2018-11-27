## Chaincode Development

Section 1: Lab overview
=======================

In this lab, we will start by exploring the environment to figure out how the machine has been set up for the labs.
We will then create a small "Hello World" chaincode, debug, instantiate and test it.

Section 2: Getting started
==========================

**Step 1:** Log in to your assigned Ubuntu 18.10 Linux on IBM Z instance using PuTTY, the OS X terminal, or the Linux terminal of your choice.
You will be greated with a message similar to this one::

  [guigui@t460 ~]$ ssh blockchain@10.3.4.168
  Welcome to Ubuntu 18.04.1 LTS (GNU/Linux 4.15.0-39-generic s390x)

   * Documentation:  https://help.ubuntu.com
   * Management:     https://landscape.canonical.com
   * Support:        https://ubuntu.com/advantage

    System information as of Tue Nov 27 17:02:45 CET 2018

    System load:                    0.11
    Usage of /:                     90.9% of 6.64GB
    Memory usage:                   25%
    Swap usage:                     0%
    Processes:                      147
    Users logged in:                1
    IP address for encd30:          10.3.4.168
    IP address for encd998:         172.23.2.206
    IP address for br-734ca1898d94: 172.19.0.1
    IP address for br-d06ef2f4a8cb: 172.18.0.1
    IP address for docker0:         172.17.0.1
    IP address for br-d7db5143436c: 172.20.0.1
    IP address for br-74f7822151ea: 172.21.0.1

    => / is using 90.9% of 6.64GB


    * MicroK8s is Kubernetes in a snap. Made by devs for devs. One quick
      install on a workstation, VM, or appliance.

     - http://bit.ly/microk8s


  0 packages can be updated.
  0 updates are security updates.


  Last login: Tue Nov 27 15:30:46 2018 from 10.32.52.233

**Step 2:** Explore the environment to find out where the go binaries are installed::

    blockchain@blkchn30:~$ which go 
    /usr/lib/go-1.9/bin/go

**Step 3:** Confirm what the exact version of the Go language installed on the machine::

    blockchain@blkchn30:~$ go version
    go version go1.9.1 linux/s390x

We have a Go version 1.9.1 version available for the s390x platform.

**Step4:** Chaincodes need to be installed in a subdirectory of the ${GOPATH}/src directory.
Using go env command, let's figure out what the value of this variable in order to identify where we need to locate our chaincode::

    blockchain@blkchn30:~$ go env GOPATH
    /home/blockchain/gopath

Our chaincode will have to go in a subdirectory of */home/blockchain/gopath/src*

Section 2: Getting the environment ready
========================================

**Step 1:** If not done already, get a copy of the instructor's GitHub repository containing sample Hyperledger Fabric docker-compose files in various configurations::

    blockchain@blkchn30:~$ cd ~
    blockchain@blkchn30:~$ git clone https://github.com/GuiGui2/fabric-configs.git

**Step 2:** Move to the fabric-configs/v1.1.x/ directory in your home folder. This directory contains all needed configuration files to start a Fabric network.

    blockchain@blkchn30:~$ cd fabric-configs/v1.1.x
    blockchain@blkchn30:~/fabric-configs/v1.1.x$ ls
    README.md  ca.yml  cas  channel-artifacts  docker-compose-kafka-couch.yml  docker-compose-kafka.yml  docker-compose-solo-couch.yml  docker-compose-solo.yml


**Step 3:** Start the Fabric using the provided docker-compose file:

    blockchain@blkchn30:~/fabric-configs/v1.1.x$ docker-compose -f docker-compose-kafka-couch.yml up -d
    Creating network "zmarbles_default" with the default driver
    Creating Org1CA       ... done
    Creating zookeeper1   ... done
    Creating couchdb1.2   ... done
    Creating couchdb1.1   ... done
    Creating OrdererOrgCA ... done
    Creating zookeeper2   ... done
    Creating couchdb2.2   ... done
    Creating Org2CA       ... done
    Creating zookeeper0   ... done
    Creating couchdb2.1   ... done
    Creating kafka3       ... done
    Creating kafka0       ... done
    Creating kafka2       ... done
    Creating kafka1       ... done
    Creating orderer0     ... done
    Creating orderer1     ... done
    Creating orderer2     ... done
    Creating orderer3     ... done
    Creating peer1.1      ... done
    Creating peer1.2      ... done
    Creating peer2.1      ... done
    Creating peer2.2      ... done
    Creating cli          ... done


**Step 4:** Ensure the containers have been started as expected using the docker ps command:

    blockchain@blkchn30:~/labconfig$ docker ps
    CONTAINER ID        IMAGE                        COMMAND                  CREATED              STATUS              PORTS                                             NAMES
    3ac1d66fc0b2        hyperledger/fabric-tools       "/bin/bash -c 'sleep…"   About a minute ago   Up About a minute   0.0.0.0:32835->9092/tcp                                                     cli
    a610741649a3        hyperledger/fabric-peer        "peer node start"        About a minute ago   Up About a minute   7050/tcp, 7052-7059/tcp, 0.0.0.0:10051->7051/tcp                            peer2.2
    4de94667c64e        hyperledger/fabric-peer        "peer node start"        About a minute ago   Up About a minute   7050/tcp, 7052-7059/tcp, 0.0.0.0:9051->7051/tcp                             peer2.1
    d53d69ed7eec        hyperledger/fabric-peer        "peer node start"        About a minute ago   Up About a minute   7050/tcp, 7052-7059/tcp, 0.0.0.0:8051->7051/tcp                             peer1.2
    bc5355c1e456        hyperledger/fabric-peer        "peer node start"        About a minute ago   Up About a minute   7050/tcp, 7052-7059/tcp, 0.0.0.0:7051->7051/tcp                             peer1.1
    e4a3b3cc3824        hyperledger/fabric-orderer     "orderer"                About a minute ago   Up About a minute   0.0.0.0:32834->7050/tcp                                                     orderer3
    b9ea898af902        hyperledger/fabric-orderer     "orderer"                About a minute ago   Up About a minute   0.0.0.0:32833->7050/tcp                                                     orderer2
    726ae9dffa64        hyperledger/fabric-orderer     "orderer"                About a minute ago   Up About a minute   0.0.0.0:32832->7050/tcp                                                     orderer1
    fe6ae2e94f07        hyperledger/fabric-orderer     "orderer"                About a minute ago   Up About a minute   0.0.0.0:32831->7050/tcp                                                     orderer0
    33b5f50ee296        hyperledger/fabric-kafka       "/docker-entrypoint.…"   2 minutes ago        Up About a minute   9093/tcp, 0.0.0.0:32830->9092/tcp                                           kafka2
    4b9b79517f69        hyperledger/fabric-kafka       "/docker-entrypoint.…"   2 minutes ago        Up About a minute   9093/tcp, 0.0.0.0:32829->9092/tcp                                           kafka1
    5707e647d5c3        hyperledger/fabric-kafka       "/docker-entrypoint.…"   2 minutes ago        Up About a minute   9093/tcp, 0.0.0.0:32828->9092/tcp                                           kafka3
    805ec2c3ca14        hyperledger/fabric-kafka       "/docker-entrypoint.…"   2 minutes ago        Up About a minute   9093/tcp, 0.0.0.0:32827->9092/tcp                                           kafka0
    33b99a94f85f        hyperledger/fabric-couchdb     "tini -- /docker-ent…"   2 minutes ago        Up 2 minutes        4369/tcp, 9100/tcp, 0.0.0.0:7984->5984/tcp                                  couchdb2.1
    de7a0b8e54dc        hyperledger/fabric-zookeeper   "/docker-entrypoint.…"   2 minutes ago        Up About a minute   0.0.0.0:32826->2181/tcp, 0.0.0.0:32825->2888/tcp, 0.0.0.0:32823->3888/tcp   zookeeper0
    775e167a2121        hyperledger/fabric-zookeeper   "/docker-entrypoint.…"   2 minutes ago        Up 2 minutes        0.0.0.0:32824->2181/tcp, 0.0.0.0:32822->2888/tcp, 0.0.0.0:32821->3888/tcp   zookeeper2
    08953f96d0ab        hyperledger/fabric-couchdb     "tini -- /docker-ent…"   2 minutes ago        Up 2 minutes        4369/tcp, 9100/tcp, 0.0.0.0:8984->5984/tcp                                  couchdb2.2
    53c54e0021b0        hyperledger/fabric-ca          "sh -c 'fabric-ca-se…"   2 minutes ago        Up About a minute   0.0.0.0:32820->7054/tcp                                                     OrdererOrgCA
    ca470393b666        hyperledger/fabric-couchdb     "tini -- /docker-ent…"   2 minutes ago        Up 2 minutes        4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp                                  couchdb1.1
    e4b6506bfb8d        hyperledger/fabric-ca          "/bin/sh -c 'fabric-…"   2 minutes ago        Up 2 minutes        0.0.0.0:32816->7054/tcp                                                     Org2CA
    a383aeb33f46        hyperledger/fabric-couchdb     "tini -- /docker-ent…"   2 minutes ago        Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:6984->5984/tcp                                  couchdb1.2
    beb7adf119b1        hyperledger/fabric-zookeeper   "/docker-entrypoint.…"   2 minutes ago        Up About a minute   0.0.0.0:32819->2181/tcp, 0.0.0.0:32818->2888/tcp, 0.0.0.0:32817->3888/tcp   zookeeper1
    7e582ee71b7c        hyperledger/fabric-ca          "sh -c 'fabric-ca-se…"   2 minutes ago        Up 2 minutes        0.0.0.0:32815->7054/tcp                                                     Org1CA


The Fabric is composed of 4 orderers, 2 peers using CouchDB as their World State per organization and a CLI we'll use in the next section to test our Smart Contract.

**Step 5:** For the Fabric to be usable, we need to create a channel, and add peers to this channel. 

    blockchain@blkchn30:~$ docker exec -it cli bash
    root@3ac1d66fc0b2:/opt/gopath/src/github.com/hyperledger/fabric/config# peer channel create -o orderer0:7050 -c mpl -f mpl.tx 
    2018-06-12 15:00:20.266 UTC [msp] GetLocalMSP -> DEBU 001 Returning existing local MSP
    2018-06-12 15:00:20.268 UTC [msp] GetDefaultSigningIdentity -> DEBU 002 Obtaining default signing identity
    2018-06-12 15:00:20.289 UTC [channelCmd] InitCmdFactory -> INFO 003 Endorser and orderer connections initialized
    2018-06-12 15:00:20.289 UTC [msp] GetLocalMSP -> DEBU 004 Returning existing local MSP
    2018-06-12 15:00:20.313 UTC [msp] GetDefaultSigningIdentity -> DEBU 005 Obtaining default signing identity
    2018-06-12 15:00:20.314 UTC [msp] GetLocalMSP -> DEBU 006 Returning existing local MSP
    2018-06-12 15:00:20.314 UTC [msp] GetDefaultSigningIdentity -> DEBU 007 Obtaining default signing identity
    2018-06-12 15:00:20.314 UTC [msp/identity] Sign -> DEBU 008 Sign: plaintext: 0AE7060A074F7267314D535012DB062D...53616D706C65436F6E736F727469756D 
    2018-06-12 15:00:20.314 UTC [msp/identity] Sign -> DEBU 009 Sign: digest: 28C4E02902BA7B0C3789F47CD21E9023B6E030E8B2B673D6A66074A7B6B77FE5 
    2018-06-12 15:00:20.315 UTC [msp] GetLocalMSP -> DEBU 00a Returning existing local MSP
    2018-06-12 15:00:20.315 UTC [msp] GetDefaultSigningIdentity -> DEBU 00b Obtaining default signing identity
    2018-06-12 15:00:20.315 UTC [msp] GetLocalMSP -> DEBU 00c Returning existing local MSP
    2018-06-12 15:00:20.315 UTC [msp] GetDefaultSigningIdentity -> DEBU 00d Obtaining default signing identity
    2018-06-12 15:00:20.315 UTC [msp/identity] Sign -> DEBU 00e Sign: plaintext: 0A98070A0F08021A060884C0FFD80522...58D1184E57DBD56A592755FD5261C391 
    2018-06-12 15:00:20.315 UTC [msp/identity] Sign -> DEBU 00f Sign: digest: 74C8863088CCBB9AEC24155BC9B739DE2C5C9A1711838F623E4CCE65459D0B3B 
    2018-06-12 15:00:20.377 UTC [msp] GetLocalMSP -> DEBU 010 Returning existing local MSP
    [...]
    2018-06-12 15:00:22.023 UTC [msp/identity] Sign -> DEBU 065 Sign: digest: 04631E571657A8756876653F2CC4927A24D5243EF640D69F6AFAA591CB209B00 
    2018-06-12 15:00:22.026 UTC [channelCmd] readBlock -> DEBU 066 Received block: 0
    2018-06-12 15:00:22.027 UTC [main] main -> INFO 067 Exiting.....
    root@3ac1d66fc0b2:/opt/gopath/src/github.com/hyperledger/fabric/config# peer channel join -b mpl.block 
    2018-06-12 15:00:32.150 UTC [msp] GetLocalMSP -> DEBU 001 Returning existing local MSP
    2018-06-12 15:00:32.150 UTC [msp] GetDefaultSigningIdentity -> DEBU 002 Obtaining default signing identity
    2018-06-12 15:00:32.152 UTC [channelCmd] InitCmdFactory -> INFO 003 Endorser and orderer connections initialized
    2018-06-12 15:00:32.153 UTC [msp/identity] Sign -> DEBU 004 Sign: plaintext: 0AE4070A5B08011A0B0890C0FFD80510...6FD49B99E97E1A080A000A000A000A00 
    2018-06-12 15:00:32.153 UTC [msp/identity] Sign -> DEBU 005 Sign: digest: E138858AAE9CC1273A393165851FA7B962F97167D524A199EDEB395CA8ED6E56 
    2018-06-12 15:00:32.554 UTC [channelCmd] executeJoin -> INFO 006 Successfully submitted proposal to join channel
    2018-06-12 15:00:32.554 UTC [main] main -> INFO 007 Exiting.....

    root@3ac1d66fc0b2:/opt/gopath/src/github.com/hyperledger/fabric/config# CORE_PEER_ADDRESS=peer1.2:7051 peer channel join -b mpl.block 
    2018-06-12 15:01:07.394 UTC [msp] GetLocalMSP -> DEBU 001 Returning existing local MSP
    2018-06-12 15:01:07.394 UTC [msp] GetDefaultSigningIdentity -> DEBU 002 Obtaining default signing identity
    2018-06-12 15:01:07.397 UTC [channelCmd] InitCmdFactory -> INFO 003 Endorser and orderer connections initialized
    2018-06-12 15:01:07.397 UTC [msp/identity] Sign -> DEBU 004 Sign: plaintext: 0AE5070A5C08011A0C08B3C0FFD80510...6FD49B99E97E1A080A000A000A000A00 
    2018-06-12 15:01:07.398 UTC [msp/identity] Sign -> DEBU 005 Sign: digest: C6571D0AA04D42B57DB4E5022791F0CE00E729918A5ADA8BDDB4A270DE4AAF7B 
    2018-06-12 15:01:07.580 UTC [channelCmd] executeJoin -> INFO 006 Successfully submitted proposal to join channel
    2018-06-12 15:01:07.580 UTC [main] main -> INFO 007 Exiting.....
    root@3ac1d66fc0b2:/opt/gopath/src/github.com/hyperledger/fabric/config# 

The fabric is now up, running and configured.

**Step 6:** Create a directory of your choice in the ${GOPATH}/src folder, like so:

    blockchain@blkchn32:~$ mkdir ${GOPATH}/src/chaincode/go

**Step 7:** Move into that directory:

    blockchain@blkchn32:~$ cd ${GOPATH}/src/chaincode/go

**Step 8:** We'll proceed in 4 steps with our chaincode. So we suggest to use 4 different subdirectories for each of the steps of the labs.

    blockchain@blkchn32:~$ mkdir step{1,2,3,4}

**Note:** In the subsequent steps, we'll assume the chaincodes are in different subdirectories, so will have different names when instantiated in the network.
Should you decide to do all your development in a single file, make sure to change versions at each step on the way.

Section 3: Chaincode development - step 1
=========================================

**Step 1:** Create a chaincode skeleton by copy-pasting the following code into a file you name at your convenience, in subfolder step1.

```golang
package main

import (
	"fmt"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type SimpleChaincode struct {
}

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

func main() {
	err:= shim.Start(new(SimpleChaincode))
	if err!= nil{
	fmt.Printf("Error starting SimpleChaincode chaincode: %s", err)
	}
}
```

**Note:** There are a number of options available for editing files in Linux. Both vim and nano editors are provided in the machines. Should you prefer something else, do feel free to install another editor. Remote editing using tools like WinSCP for instance is also entirely possible.

**Step 2:** It is usually a good idea to try and compile the chaincode before installing and instantiating it. Try and compile the skeleton we created in step1/step1.go to identify potential syntax errors and fix them in advance, if any: 

    blockchain@blkchn32:~/gopath/src/chaincode/step1$ go build -v step1.go 
    github.com/hyperledger/fabric/bccsp
    github.com/hyperledger/fabric/bccsp/utils
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/grpclog
    github.com/hyperledger/fabric/common/flogging
    github.com/hyperledger/fabric/common/metadata
    github.com/hyperledger/fabric/protos/msp
    github.com/hyperledger/fabric/bccsp/sw
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/codes
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/credentials
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/internal
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/keepalive
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/metadata
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/naming
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/peer
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/stats
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/status
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/tap
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc/transport
    github.com/hyperledger/fabric/bccsp/pkcs11
    github.com/hyperledger/fabric/bccsp/factory
    github.com/hyperledger/fabric/common/util
    github.com/hyperledger/fabric/protos/common
    github.com/hyperledger/fabric/vendor/google.golang.org/grpc
    github.com/hyperledger/fabric/common/ledger
    github.com/hyperledger/fabric/protos/ledger/queryresult
    github.com/hyperledger/fabric/common/crypto
    github.com/hyperledger/fabric/core/container/util
    github.com/hyperledger/fabric/core/chaincode/platforms/util
    github.com/hyperledger/fabric/bccsp/signer
    github.com/hyperledger/fabric/msp
    github.com/hyperledger/fabric/core/comm
    github.com/hyperledger/fabric/protos/peer
    github.com/hyperledger/fabric/core/chaincode/platforms/golang
    github.com/hyperledger/fabric/core/chaincode/platforms/car
    github.com/hyperledger/fabric/core/chaincode/platforms/java
    github.com/hyperledger/fabric/core/chaincode/platforms
    github.com/hyperledger/fabric/protos/utils
    github.com/hyperledger/fabric/core/chaincode/shim
    command-line-arguments

**Step 3:** Also make sure the resulting binary can be launched:

    blockchain@blkchn32:~/gopath/src/chaincode/go/step1$ ./step1 
    2017-10-20 15:01:31.189 CEST [shim] SetupChaincodeLogging -> INFO 001 Chaincode log level not provided; defaulting to: INFO
    2017-10-20 15:01:31.189 CEST [shim] SetupChaincodeLogging -> INFO 002 Chaincode (build level: ) starting up ...
    Error starting SimpleChaincode chaincode: Error chaincode id not providedblockchain@blkchn32:~/gopath/src/chaincode/step1$ 

**Step 4:** The chaincode compiles and runs, but does nothing outside of the Fabric. This is what the error message suggests. 
The next step is to instantiate it in the Fabric. In order to do that, we'll use the CLI container which has been started as part of the Fabric. Let's connect to the CLI container:

    blockchain@blkchn32:~/gopath/src/chaincode/go/step1$ docker exec -it cli /bin/bash
    root@@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer# 

**Step 5:** Now is time to install the chaincode onto the peer.

    root@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer# peer chaincode install -n step1 -v1.0 -p chaincode/go/step1
    2017-10-23 08:49:58.634 UTC [msp] GetLocalMSP -> DEBU 001 Returning existing local MSP
    2017-10-23 08:49:58.634 UTC [msp] GetDefaultSigningIdentity -> DEBU 002 Obtaining default signing identity
    2017-10-23 08:49:58.635 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default escc
    2017-10-23 08:49:58.635 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default vscc
    2017-10-23 08:49:58.708 UTC [golang-platform] getCodeFromFS -> DEBU 005 getCodeFromFS chaincode/step1
    2017-10-23 08:49:58.876 UTC [golang-platform] func1 -> DEBU 006 Discarding GOROOT package fmt
    2017-10-23 08:49:58.876 UTC [golang-platform] func1 -> DEBU 007 Discarding provided package github.com/hyperledger/fabric/core/chaincode/shim
    2017-10-23 08:49:58.876 UTC [golang-platform] func1 -> DEBU 008 Discarding provided package github.com/hyperledger/fabric/protos/peer
    2017-10-23 08:49:58.876 UTC [golang-platform] GetDeploymentPayload -> DEBU 009 done
    2017-10-23 08:49:58.879 UTC [msp/identity] Sign -> DEBU 00a Sign: plaintext: 0AE4070A5C08031A0C08B6DAB6CF0510...C605F81D0000FFFF6E0DB560000A0000 
    2017-10-23 08:49:58.879 UTC [msp/identity] Sign -> DEBU 00b Sign: digest: 17B3F347C00AC33486C9AE7E31B7484926F528F36351C00BD2D3DD56D7A95CBC 
    2017-10-23 08:49:58.885 UTC [chaincodeCmd] install -> DEBU 00c Installed remotely response:<status:200 payload:"OK" > 
    2017-10-23 08:49:58.885 UTC [main] main -> INFO 00d Exiting.....
    root@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer#  

The **peer chaincode install** command requires the following arguments:

* *-n* specifies the name of the chaincode you want to deploy
* *-v* specifies the version of the chaincode you're about to deploy
* *-p* points to the folder in which to find the chaincode to install, relatively to ${GOPATH}/src 

**Step 6:** Final part of the deployment is to instantiate the chaincode. This will build a specific container, bound to a specific peer, that will execute the chaincode.

    root@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer# peer chaincode instantiate -o orderer0:7050 -n step1 -v1.0 -C mpl -c '{"Args":["Init"]}' -P "OR('Org1MSP.member')"
    2017-10-23 08:56:41.586 UTC [msp] GetLocalMSP -> DEBU 001 Returning existing local MSP
    2017-10-23 08:56:41.586 UTC [msp] GetDefaultSigningIdentity -> DEBU 002 Obtaining default signing identity
    2017-10-23 08:56:41.590 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default escc
    2017-10-23 08:56:41.590 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default vscc
    2017-10-23 08:56:41.590 UTC [msp/identity] Sign -> DEBU 005 Sign: plaintext: 0AF0070A6808031A0C08C9DDB6CF0510...434D53500A04657363630A0476736363 
    2017-10-23 08:56:41.590 UTC [msp/identity] Sign -> DEBU 006 Sign: digest: D669F659E4A4D70084F672FC0A0CBDE09864BB14584A58A548155C423CFF891A 
    2017-10-23 08:56:59.556 UTC [msp/identity] Sign -> DEBU 007 Sign: plaintext: 0AF0070A6808031A0C08C9DDB6CF0510...4C0A711FEA0712CC97744248D6ED64BC 
    2017-10-23 08:56:59.556 UTC [msp/identity] Sign -> DEBU 008 Sign: digest: D12BBFE967AF11D2AE6D32F70B995569048280ADE1CDA7DC3646BDF07F585487 
    2017-10-23 08:56:59.558 UTC [main] main -> INFO 009 Exiting.....
    root@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer# 

The **peer chaincode instantiate** command takes the following arguments:
 
* *-o* specifies the ordering service to converse with
* *-n* specifies the name of the chaincode you want to instantiate
* *-p* specifies the version of said chaincode
* *-C* is the channel onto which the chaincode will be instantiated
* *-c* contains the list of arguments to pass to the chaincode when instantiated. In this case, we specifiy the Init parameter, to execute the Init method when the chaincode is instatntiated.
* *-P* specifies the endorsement policy for this chaincode on this channel

**Note:** Upon successful instantiation, you will notice a new container running in your environment, like so:

    blockchain@blkchn30:~$ docker ps |grep step1
    CONTAINER ID        IMAGE                                                                                  COMMAND                  CREATED             STATUS              PORTS                                             NAMES
    b2b07b68df48        dev-peer1.1-step1-1.0-71189b25530a3dd0519aafc23b0dba073e3d567416c7dad58745b40ffbc13ce6   "chaincode -peer.a..."   7 minutes ago       Up 7 minutes                                                          dev-peer0-step1-1.0

Section 4: Chaincode development - step 2
=========================================

**Step 1:** Copy the template for step1 over to step2, as step2.go

    blockchain@blkchn30:~/gopath/src/chaincode/go/step2$ cp ../step1/step1.go step2.go

**Step 2:** Let's modify our previous, functional yet useless, chaincode to store a vkey and its value in the ledger as part of the chaincode initialization process.
Suggested if to use the PutState method to store a key of your choice, together with its value. These attributes will be passed to the Init function using the -c argument on the *peer chaincode instantiate* command. Make sure to add some logs and outputs.

**Note:** Instructor provided example can be found in the go/step2 subfolder in this directory.

**Step 3:** Install, instantiate and check to effect of the Init. The steps to follow are similar to steps 5 and 6 in the previous section. Using the instructor-provided example show the following output when instantiated:

    root@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer# peer chaincode install -n step2 -v1.0 -p chaincode/go/step2
    2017-10-23 11:32:12.085 UTC [msp] GetLocalMSP -> DEBU 001 Returning existing local MSP
    2017-10-23 11:32:12.085 UTC [msp] GetDefaultSigningIdentity -> DEBU 002 Obtaining default signing identity
    2017-10-23 11:32:12.085 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default escc
    2017-10-23 11:32:12.085 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default vscc
    2017-10-23 11:32:12.134 UTC [golang-platform] getCodeFromFS -> DEBU 005 getCodeFromFS chaincode/step2
    2017-10-23 11:32:12.276 UTC [golang-platform] func1 -> DEBU 006 Discarding GOROOT package fmt
    2017-10-23 11:32:12.276 UTC [golang-platform] func1 -> DEBU 007 Discarding provided package github.com/hyperledger/fabric/core/chaincode/shim
    2017-10-23 11:32:12.276 UTC [golang-platform] func1 -> DEBU 008 Discarding provided package github.com/hyperledger/fabric/protos/peer
    2017-10-23 11:32:12.276 UTC [golang-platform] GetDeploymentPayload -> DEBU 009 done
    2017-10-23 11:32:12.279 UTC [msp/identity] Sign -> DEBU 00a Sign: plaintext: 0AE4070A5C08031A0C08BCA6B7CF0510...FF06DF030000FFFF9C34A79C000A0000 
    2017-10-23 11:32:12.281 UTC [msp/identity] Sign -> DEBU 00b Sign: digest: A61A7AFE8329C44EB7FFF7DDD8EF2AF7E3FB1CD90C1EE2ECDB17A013B96D4DDB 
    2017-10-23 11:32:12.286 UTC [chaincodeCmd] install -> DEBU 00c Installed remotely response:<status:200 payload:"OK" > 
    2017-10-23 11:32:12.286 UTC [main] main -> INFO 00d Exiting.....

    root@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer# peer chaincode instantiate -o orderer0:7050 -n step2 -v1.0 -C mpl -c '{"Args":["Init"]}' -P "OR('Org1MSP.member')"
    2017-10-23 11:32:35.441 UTC [msp] GetLocalMSP -> DEBU 001 Returning existing local MSP
    2017-10-23 11:32:35.441 UTC [msp] GetDefaultSigningIdentity -> DEBU 002 Obtaining default signing identity
    2017-10-23 11:32:35.444 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default escc
    2017-10-23 11:32:35.444 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default vscc
    2017-10-23 11:32:35.445 UTC [msp/identity] Sign -> DEBU 005 Sign: plaintext: 0AF0070A6808031A0C08D3A6B7CF0510...434D53500A04657363630A0476736363 
    2017-10-23 11:32:35.445 UTC [msp/identity] Sign -> DEBU 006 Sign: digest: 49DF6119C0D03C419980D7F5233DB9F5586ED3CFCF22690CCB39A1DF4C02FEBE 
    2017-10-23 11:32:52.787 UTC [msp/identity] Sign -> DEBU 007 Sign: plaintext: 0AF0070A6808031A0C08D3A6B7CF0510...E8287D81FD1DF8DE61442EDED9B09218 
    2017-10-23 11:32:52.787 UTC [msp/identity] Sign -> DEBU 008 Sign: digest: A0CA2D1FF152690F3D1BF1B558E47AFC457505F3128643B235459B7BDF44A35A 
    2017-10-23 11:32:52.791 UTC [main] main -> INFO 009 Exiting.....

**Step4:** Check the chaincode container logs to figure out what happened:

    blockchain@blkchn30:~/gopath/src/chaincode/go/step2$ docker ps | grep step2
    79f6458d4414        dev-peer0-step2-1.0-e1816cadb82738bfe84fef246feaac1ced6553b3ee106a7f4dc03f498fe9a6bb   "chaincode -peer.a..."   About a minute ago   Up About a minute                                                     dev-peer0-step2-1.0
    blockchain@blkchn30:~/gopath/src/chaincode/go/step2$ docker logs 79f6458d4414
    Initializing chaincode SimpleChaincode
    blockchain@blkchn30:~/gopath/src/chaincode/step2$ 

**Note:** You can use the CouchDB database to visualize the effect of the Init()ialization of the ledger.

Section 5: Chaincode development - step 3
==========================================

**Step 1:** Copy the file step2/step2.go over to step3 as step3.go

**Step 2:** Implement the query function which will be used to query the ledger.
* Add a call to GetFunctionAndParameters at the top of the Invoke() function to retrieve the name of the function and the arguments it's been called with.
* Add a switch case in the Invoke() function to call the "query" function when the name of the function called matches query.
* Retrieve the value of the key specified as an argument.
* Print that key in the output.

**Note:** In the step3 subfolder is an example provided.

**Step 3:** Install, instantiate and test the function works as expected.
Using the example provided, the output is as follows:

    root@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer# peer chaincode query -n step3 -C mpl -c '{"Args":["query","Hello"]}'
    2017-10-24 08:09:11.764 UTC [msp] GetLocalMSP -> DEBU 001 Returning existing local MSP
    2017-10-24 08:09:11.764 UTC [msp] GetDefaultSigningIdentity -> DEBU 002 Obtaining default signing identity
    2017-10-24 08:09:11.764 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default escc
    2017-10-24 08:09:11.764 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default vscc
    2017-10-24 08:09:11.765 UTC [msp/identity] Sign -> DEBU 005 Sign: plaintext: 0AF1070A6908031A0C08A7EABBCF0510...1A0E0A0571756572790A0548656C6C6F 
    2017-10-24 08:09:11.765 UTC [msp/identity] Sign -> DEBU 006 Sign: digest: 0E470F66A32C412A526E9965895381D0F53C9985B741AE1E9655816C19C9F49B 
    Query Result: World!
    2017-10-24 08:09:11.788 UTC [main] main -> INFO 007 Exiting.....
    root@2b839fc94578:/opt/gopath/src/github.com/hyperledger/fabric/peer# 

**Step4:** Also check the output of the chaincode container, if you add any debug statements in there. Using the example provided, it looks as follows:

    blockchain@blkchn30:~/gopath/src/chaincode/go/step3$ docker logs cc8a660db67e
    Initializing chaincode SimpleChaincode
    Invoking chaincode SimpleChaincode
    Query Response:{"Name":"Hello","Amount":"World!"}

Section 6: Chaincode development - step 4
=========================================

**Step 1:** Copy the file step3/step3.go over to step4 as step4.go

**Step 2:** Implement the invoke function which will be used to update the ledger.

**Step 3:** Install, instantiate and test the function works as expected.
