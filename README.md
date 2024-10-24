# Shibboleth IdP Version 5 Installer

## Overview
The  Shibboleth IdPv5 Installer is designed by AAF and it is modified to automate the install of version 5 for the [Shibboleth IdP] for LIAF members.(https://shibboleth.atlassian.net/wiki/spaces/IDP5/overview) on a dedicated server with one of the following supported operating systems;
* Rocky Linux 8 or 9
* Stream 8 or Stream 9
* Redhat 8 or 9
* ORACLE Linux 8 or 9
* Ubuntu 20.04 (Focal Fossa), 22.04 (Jammy Jellyfish), 24.04 (Noble Numbat)

For a full set of documentation and guidance on upgrading from Shibboleth version 4 please refer to the [AAF IdPv4 Installer Knowledge base](https://support.aaf.edu.au/support/solutions/articles/19000159910-shibboleth-idp-version-5-installer).

## Status
This software is actively being developed and maintained. It is ready for use in production environments.

This version now enables the technical connection to eduGAIN, the global federation of federations.

This release is for Shibboleth version 5.1.3 running on Jetty 12.0.12

## License
Apache License Version 2.0, January 2004

## Required Checklist

A dedicated Ubuntu 20.04 (virtual or physical) or RedHAT 7 or 8 or CentOS 7, 8 or Stream, with the following minimum specifications:

```
2 CPU
4GB RAM
10GB+ partition for OS
```
### Server Connectivity

* You MUST have SSH access to the server
* You MUST be able to execute commands as root on the system without limitation
* The server MUST be routable from the public internet with a static IP. Often this means configuring the IP on a local network interface directly but advanced environments may handle this differently.
* The static IP MUST have a publicly resolvable DNS entry. Typically of the form idp.YOUR-DOMAIN.ac.lk
* The server MUST be able to communicate with the wider internet without blockage due to firewall rules.

### Installation Steps

1.Install Ubuntu 24.04 LTS or your selected OS (list given above).

2. Become ROOT:
   ```sudo su -```
   
3. Update the OS
   ```apt-get update && apt-get upgrade```
   
4. Change TimeZone w.r.t to Sri Lanka:
   ```sudo timedatectl set-timezone Asia/Karachi  ```

5. Set the IdP hostname, The public domain name of the IdP may be used in determined the entityID of the IdP.

(ATTENTION: Replace ```idp.YOUR-DOMAIN.ac.lk``` with your IdP Full Qualified Domain Name and ```<HOSTNAME>``` with the IdP hostname)
   
```<YOUR SERVER IP ADDRESS> idp.example.org <HOSTNAME>```

6. Install Python3 and Ansible Package

```sudo apt install ansible python3```

7. For new installations download the bootstrap-v5.ini file as follows;
```
curl https://raw.githubusercontent.com/LEARN-LK/shibboleth-idp5-installer/master/bootstrap-v5.ini > bootstrap-v5.ini
```
Edit the ```bootstrap-v5.ini``` file;

A description of each field is provided here and in the downloaded version of ```bootstrap-v5.in```

```
vi bootstrap-v5.ini
```

You MUST review, configure and uncomment each field listed in the [main] section

If you have LDAP details you SHOULD also configure the [ldap] section

8. Running the installer

Download and prepare the bootstrap-v4.sh for execution using the following command;

```
curl https://raw.githubusercontent.com/LEARN-LK/shibboleth-idp5-installer/master/bootstrap-v5.sh > bootstrap-v4.sh && chmod u+x bootstrap-v5.sh
```
Ensure that bootstrap-v5.ini is in the same directory used to download the bootstrap-v5.sh script.

Run the following command as root; 
````
./bootstrap-v5.sh
````

The bootstrap-v5 process will now install and configure your server to operate as a Shibboleth IdP.

9. Event logging

The installer provides a detailed set of information indicating the steps it has undertaken on your server. You MAY disregard this output if the process completes successfully.

For future review all installer output is logged to

```/opt/shibboleth-idp-installer/activity.log```

10. Check the IdP logs

The IdP writes its four log files into the directory ```/var/log/shibboleth-idp```. It may take a few minutes for the log files to appear the first time the IdP starts.

Check ```idp-warn.log``` for any errors. This should only contain two Deprecation warnings that can be ignored.

Check ```idp-process.log``` from any ERRORS and and verify the Servlet has started. You should find the following content near the end of the file.

11. Accessing the IdP

The IdP server should be responding the incoming requests. A web browser is simplest way to perform these tests but curl or wget will work.

The name of you IdP server should be the same as the value you supplied in the HOST_NAME value in bootstrap-v4.ini.

The IdP should NOT be listening on port 80.

    ```http://idp.YOUR-DOMAIN.ac.lk```

The IdP should be listening on port 443. Attempting to access the root level of the IdP will redirect you to https://ac.lk/ [Note: You will change this address later in the configuration].

```
https://idp.YOUR-DOMAIN.ac.lk
https://idp.YOUR-DOMAIN.ac.lk
https://idp.YOUR-DOMAIN.ac.lk/idp/shibboelth
```
### Errors during installation

If an error occurs, the logs prior to installer termination MUST be reviewed to understand the underpinning cause.

Generally the installer SHOULD be executed once.

After the initial execution you’ll receive an error if you try to run bootstrap.sh again.

You MUST NOT re-run bootstrap-v5.sh if the installation process completed but you made a simple mistake. e.g.
```
*   Mistyped config in the [main], [ldap] or [advanced] sections
```

If you force bootstrap-v5.sh to run again once initial installation has completed the action MAY be destructive.

### Allowing the installer to run again

In general you will never need to re-run the bootstrap-v5.sh script after it has completed creating the ```/opt/shibboleth-v5-installer``` directory.

You should use the ```deploy``` or ```upgrade``` scripts instead.

If you must re-run bootstrap-v5.sh then you remove the lock file first. Note this will overwrite any previous installations.
```
    rm /root/.lock-idp-bootstrap-v5 && ./bootstrap-v5.sh
```
The bootstrap-v5 process will now start over and attempt to install and configure your server to operate as a Shibboleth IdP.

### When Bootstrap-v5.sh completes

When the scripts completes the mariadb, jetty and the IdP should be running. The IdP probably will not be able to authenticate and there may be some errors in the Shibboleth log file /var/log/shibboleth-idp/idp-warn.log. This is a good start but indicates that additional configuration is required.

### Using the new Hello World feature

Using the new Hello World feature introduced at version 4.1. It should show the default login page. You can try entering your credentials and one of two outcomes will occur;

1. Successful login and you receive an Access Denied message. You need to configure the AccessByAdminUser adding your username to use. You will receive a list of your attributes as an Admin User.

2. Successful login and you receive an Uncaught Exception error message. This is caused be a requirement of the auEduPersonSharedToken generator. It requires the entityID of the IdP to be passed to it when generated a shared token for a user. Hello world does not provide this value. If the user already has a shared token it will be returned.

```https://idp.YOUR-DOMAIN.ac.lk/idp/profile/admin/hello```

### Environmental data for your IdP in bootstrap-v5.ini

The following information is required by the IdP Installer and must be populated into the bootstrap-v5.ini file prior to running the installer.

Host Name The public domain name of the IdP. May be used in determined the entityID of the IdP.

Entity ID The unique technical name of the IdP. If migrating from an older IdP then its entity id should be used on the new IdP.

Environment A determination of the PKIFED federation you wish to register your IdP within, being test or production.

Organisation Name The human readable display name of your organisation

Organisation base domain e.g. example.edu, used for the scope of user's scoped attributes

Install base Where in the file system you want the IdP to be installed. The default is /opt

Patch System Software If enabled, the operating system software will be updated every time the IdP is deployed, that is the command "yum update -y" will be executed. If you have your own system patching regime in place you can disable this feature. (Default is enabled.)

eduGAIN enabled Additional configuration is enabled to allow the IdP to technically connect to eduGAIN. See eduGAIN for more information and how to join eduGAIN. (Default is enabled.)

Local firewall enabled If enabled, firewalld will be enabled and configured on the server allowing. (Default is enabled.)

Back-Channel enabled If enabled, the IdP will support back-channel requests. (Default is NOT enabled.)

### How the Shibboleth IdP installer manages your configuration

```IMPORTANT: All modifiable configuration is housed in the directory: ```

/<INSTALL_BASE>/shibboleth-idp5-installer/repository/assets/<HOST_NAME>

By default <INSTALL_BASE> = /opt`

If you make configuration changes directly within /opt/shibboleth/shibboleth-idp, /opt/jetty or elsewhere your installation will become unsupported and you may have difficulties when upgrading.

### Updating the Shibboleth IdP with customisations

### Deploy

To deploy the changes you have made to the IdP run the deploy script.

```/opt/shibboleth-idp5-installer/repository/deploy```

Changes to your assets area will be deployed to the operational IdP and the IdP will be restated. There will be a short outage of the IdP as it is restarted, usually less than 2 minutes.

##### Actions undertaken during an deployment

The deploy process will perform the following:

1. Update underlying operating system packages to ensure any security issues are addressed

2. Apply any configuration changes made within the assets directory for:

    * Shibboleth IdP
    * Jetty
3. RESTART all dependant processes.

You MUST have a tested rollback plan in place before running an deployment to ensure any unanticipated changes can be reversed.

### Upgrade

To upgrade to a later version of the IdP or supporting software run the upgrade script.

```/opt/shibboleth-idp5-installer/repository/upgrade```

This action only upgrades the Ansilbe configuration, tasks and templates used to deploy the IdP. It will NOT deploy the changes. You MUST deploy the IdP as a separate step for the changes to the Ansible files to be effected.

### Actions undertaken during an upgrade

The Ansible configuration is synced with the contents of the IdP v5 installer Git Hub repository. Changes made by the LIAF will be reflected in your repository ready for the next deployment. Changes could include

Minor bug fixes and improvements to the installer
Changes to versions of software to be installer, generally Shibboleth or Jetty
Additional functionally being added to the IdP

### Common commands

##### Deploy changes in your repository to your IdP

```/opt/shibboleth-idp5-installer/repository/deploy```

##### Restart the IdP (Jetty)

```systemctl restart idp```
