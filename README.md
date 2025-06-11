# Raspberry pi configuration and Nomad installation

The nomad cluster is installed and configured via ansible. 

The `main.yml` playbook will automatically configure networking, drive mounts, install nomad, consul and vault. NFS is used as the communication protocol between the cluster and the NAS.

Following the advice from (here) from before running it for the first time a good advice is to use the MAC address of each Pi and map them to a set of static IP addresses. For the process to be even smoother make sure you've ran ssh-agent and set up your ssh key on the Pis. The first time you run the playbook make sure you write the _current_ IP addresses of the Pis under [pis]. Firstly, we will set the static IPs for the Pis, therefore we will use the `network` tag.

To run the playbook:

`ansible-playbook -i inventory main.yaml --tags network`

If you haven't set up the ssh keys run the following:

`ansible-playbook -i -k inventory main.yaml --tags network

Now we can proceed and install nomad

## Deploying services to Nomad

All the nomad services are in the nomad-service folder. Each file is written in HCL (Hashicorp's Configuration Language).

1. Install nomad in your host machine.
2. Run `export NOMAD_ADDR=http://192.168.0.222:4646` (or set it to your chosen static IP) to export the Nomad server's address so you can deploy the services.
3. Run `nomad job run nomad-services/paperless.nomad`

To pass variable names in the job file create a file _jobname.vars_ as described by the manual. For example to pass the variable names in `paperless.nomad` run:

`nomad job run nomad-services/paperless.nomad vars-file=paperless.vars`


## Packer

In order to execute the commands in this step you need to have [packer](https://www.packer.io/) installed on your host PC.

The file `debian.json` includes the configuration of a custom debian image for the Pis. To create it with Packer, type the following:

`sudo packer build -var wifi_name=WIFI_NAME -var wifi_password=WIFI_PASSWORD debian.json`

After the build finishes it will create a `raspberry-pi.img` file. To flash the image to a USB/SD card using dd type the following (it's assumed that /dev/sda/ is the sd card/USB, otherwise change accordingly):

`sudo dd if=raspberry-pi.img of=/dev/sda bs=1M status=progress`

## Acknowledgments

- [Pi Dramble](https://github.com/geerlingguy/raspberry-pi-dramble)
- [hashi-homelab](https://github.com/perrymanuk/hashi-homelab)
- [hashi-homelab](https://github.com/aldoborrero/hashi-homelab)
- [home-lab](https://github.com/assareh/home-lab)
- [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm)
