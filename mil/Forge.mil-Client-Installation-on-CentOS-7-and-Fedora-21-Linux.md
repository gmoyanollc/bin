# Forge.mil Client Installation on CentOS-7 and Fedora-21 Linux
Forge.mil has a PKI-enabled client called ForgeSCMC (Forge Source Code Management Client).  

To configure a smartcard reader for PKCS#11 on Centos, see [Smart-Card-Reader-PKCS-11-on-CentOS-7-Linux] (./Smart-Card-Reader-PKCS-11-on-CentOS-7-Linux.md) or (https://github.com/gmoyanollc/bin/blob/master/mil/Smart-Card-Reader-PKCS-11-on-CentOS-7-Linux.md):

# Install ForgeSCMC
  
  1. Download [ForgeSCMC](https://software.forge.mil/sf/go/projects.git-gerrit/frs.forgescmc)
  
  2. Install the downloaded package
```
    $ sudo yum install ForgeSCMC-linux-amd64_1.3.3.rpm
```
  3. Launch ForgeSCMC
```
    $ bash forgeSCMC.sh
```
  
# Additional Resources
  
  * Forge.mil: [Support](https://software.forge.mil/sf/projects/support)
  
  * Forge.mil: [Git and Gerrit](https://software.forge.mil/sf/projects/git-gerrit)
  
  * Forge.mil: [GIT and Gerrit PKI Enabled Clients](https://software.forge.mil/sf/go/page3501)
  
  * Forge.mil: [ForgeSCMC Configuration and Usage](https://software.forge.mil/sf/go/doc82684)
  
# [George Moyano](https://onename.com/gmoyano)
# @github/gmoyanollc
# 2018-05-02 12:33:48 
