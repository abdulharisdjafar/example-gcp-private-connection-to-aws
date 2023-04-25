# example-gcp-private-connection-to-aws

## How to run it
1. Setup root directory environment with running command:
    ```export TF_VAR_ROOT_PATH=$PWD```
2. Setup aws environment for using terraform command
3. setup gcp environment for using terraform command
4. run ```apply.sh``` for create all the instances

## Explanation
When running ```apply.sh``` script, it will create the ha-vpn first in gcp, then create aws vpn. last the script will peering both gcp and aws vpn.
