# Smart-Card-Reader-PKCS-11-on-CentOS-7-Linux
For Linux, the installation may take the following general steps if the system is not already using PKCS#11 with a smartcard reader:

  1. Download U.S. Federal Government certificates
  
  2. Install `Enterprise Security Client Smart Card Client` (esc)
  
  3. Add browser PKCS#11 module and import certificates
  
## Download U.S. Federal Government certificates

  1. Download [DoD PKI CA Certificates](https://dl.cyber.mil/pki-pke/zip/certificates_pkcs7_DoD.zip) from [Public Key Infrastructure/Enabling (PKI/PKE) For Administrators, Integrators and Developers](https://cyber.mil/pki-pke/admins/).

## Install `Enterprise Security Client Smart Card Client`
  
  1. Install esc
```  
    $ sudo yum install esc
``` 
  2. Start `PC/SC Lite` daemon
```
    $ sudo pcscd
```
  3. Check if it is running 
```
    $ ps aux | grep pcscd
```
  4. Launch `Smart Card Manager`
```
    $ esc
```

## Add browser PKCS#11 module and import certificates

  1. Open browser's certificate configuration page
```
    Firefox/Preferences/Advanced/Certificates
```
  2. Add a PKCS#11 Device
  ```
    Firefox/Preferences/Privacy & Security/Security/Certificates/Security Devices/Load
  ```
  3. Add a PKCS#11 Device module provider
  ```
    Module Name: CoolKey PKCS#11 Module
    Module filename: /usr/lib64/libcoolkeypk11.so
  ```
  4. View and Import Authority Certificates
  ```
    Firefox/Preferences/Privacy & Security/Security/Certificates/View Certificates/Authorities/Import
  ```
  5. Select and trust US Government Authority Certificate Root files
  ```
    * Certificates_PKCS7_v5.3_DoD_DoD_Root_CA_5.der.p7b
    * Certificates_PKCS7_v5.3_DoD_DoD_Root_CA_4.der.p7b
    * Certificates_PKCS7_v5.3_DoD_DoD_Root_CA_3.der.p7b
    * Certificates_PKCS7_v5.3_DoD_DoD_Root_CA_2.der.p7b
  ```
  6. View U.S. Government Authority Certificates
  ```
    Firefox/Preferences/Privacy & Security/Security/Certificates/View Certificates/Authorities/Certificate Name/U.S. Government
  ```
## Test
  1. Browse to [](https://mattermost.cyberforce.site)
  2. Select `CAC Users`.
  3. Expect a CAC PIN prompt for success.
   
#Additional Resources

  * DISA: [Getting Started with Linux](http://iase.disa.mil/pki-pke/getting_started/Pages/linux.aspx)
  
  * DISA: [Getting Started with Firefox on Linux](http://iase.disa.mil/pki-pke/getting_started/Pages/linux-firefox.aspx)


# [George Moyano](https://onename.com/gmoyano)
# @github/gmoyanollc
# 2018-05-02 12:33:48 
