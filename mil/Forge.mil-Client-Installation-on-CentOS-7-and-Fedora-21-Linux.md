#Forge.mil Client Installation on CentOS-7 and Fedora-21 Linux
Forge.mil has a PKI-enabled client called ForgeSCMC (Forge Source Code Management Client).  On Linux, the installation may take the following general steps if the system is not already using PKCS#11 with a smartcard reader:

  1) Download U.S. Federal Government certificates
  
  2) Install PKCS#11 software provider
  
  3) Install smartcard reader software
  
  4) Add browser PKCS#11 module and import certificates
  
  5) Install ForgeSCMC
  
##Download U.S. Federal Government certificates

  1) Download [DoD Root and Intermediate CA Certificates](http://iase.disa.mil/pki-pke/Documents/unclass-installroot_v3-16-1a.zip)

##Install PKCS#11 provider

  1) Download [CACKey](http://cackey.rkeene.org/fossil/wiki?name=Downloads)
  
  2) Install from the downloaded package
```  
    sudo yum install ~/Downloads/cackey-0.6.8-3522.x86_64.rpm
``` 
  3) List the files.
```
    ls /usr/lib64/libcackey*
```

##Install smartcard reader software

  1) Install from the system repository
```  
    sudo yum install pcsc-lite
```  
  2) Start the daemon
```
    pcscd
```
  3) Check if it is running 
```
    ps aux | grep pcsc
```
##Add browser PKCS#11 module and import certificates

  1) Open browser's certificate configuration page
```
    Firefox/Preferences/Advanced/Certificates
```
  2) Add a PKCS#11 Device
  ```
    Firefox/Preferences/Advanced/Certificates/Security Devices/Load
  ```
  3) Add a PKCS#11 Device module provider
  ```
    Module Name: CACKey PKCS#11 Module
    Module filename: /usr/lib64/libcackey.so
  ```
  4) View and Import Authority Certificates
  ```
    Firefox/Preferences/Advanced/Certificates/View Certificates/Authorities/Import
  ```
  5) Select and trust US Government Authority Certificate file
  ```
    Certificates_PKCS7_v4.0.1_DoD.der.p7b
  ```
  6) View U.S. Government Authority Certificates
  ```
    Firefox/Preferences/Advanced/Certificates/View Certificates/Authorities/Certificate Name/U.S. Government
  ```
  7) Browse to Forge.mil project [ForgeSCMC](https://software.forge.mil/sf/go/projects.git-gerrit/frs.forgescmc)
  
##Install ForgeSCMC
  
  1) Download [ForgeSCMC](https://software.forge.mil/sf/go/projects.git-gerrit/frs.forgescmc)
  
  2) Install from the downloaded package
```
    yum install ForgeSCMC-linux-amd64_1.2.2.rpm
```
  2) Select and open ForgeSCMC short-cut in menu system
  
#Additional Resources

  * [Getting Started with Linux](http://iase.disa.mil/pki-pke/getting_started/Pages/linux.aspx)
  
  * [Getting Started with Firefox on Linux](http://iase.disa.mil/pki-pke/getting_started/Pages/linux-firefox.aspx)
  
  * [Forge.mil Support](https://software.forge.mil/sf/projects/support)
  
  * [Forge.mil Git and Gerrit](https://software.forge.mil/sf/projects/git-gerrit)
  
  * [Forge.mil GIT and Gerrit PKI Enabled Clients](https://software.forge.mil/sf/go/page3501)
  
  * [ForgeSCMC Configuration and Usage](https://software.forge.mil/sf/go/doc82684)
  

