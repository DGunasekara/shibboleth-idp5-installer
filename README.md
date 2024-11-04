# Shibboleth IdP Version 5 Installer

## Overview

The Shibboleth IdP Installer is designed to automate the install of version 5 for the [Shibboleth IdP](https://shibboleth.atlassian.net/wiki/spaces/IDP5/overview) on a dedicated server with one of the following supported operating systems;
* Rocky Linux 8 or 9
* Stream 8 or Stream 9
* Redhat 8 or 9
* ORACLE Linux 8 or 9
* Ubuntu 20.04 (Focal Fossa), 22.04 (Jammy Jellyfish)

Status

This installer is forked from AAF's shibboleth idp installer repository with some modifications to work with LIAF. This software is actively being developed and maintained. It is ready for use in production environments.

## Status
This software is actively being developed and maintained. It is ready for use in production environments.

This version now enables the technical connection to eduGAIN, the global federation of federations.

This release is for Shibboleth version 5.1.3 running on Jetty 12.0.12

## License
Apache License Version 2.0, January 2004

Required Checklist

A dedicated server (virtual or physical) with the following minimum specifications:

* 2 CPU
* 4GB RAM
* 10GB+ partition for OS
* Server connectivity

* You MUST have SSH access to the server
* You MUST be able to execute commands as root on the system without limitation
* The server MUST be routable from the public internet with a static IP. Often this means configuring the IP on a local network interface directly but advanced environments may handle this differently.
* The static IP MUST have a publicly resolvable DNS entry. Typically of the form ```idp.YOUR-DOMAIN.ac.lk```
* The server MUST be able to communicate with the wider internet without blockage due to firewall rules.

### Installation Steps

* Become ROOT:

```sudo su -```

* Update the OS

```apt-get update && apt-get upgrade```

* Change TimeZone w.r.t to your country:

```sudo timedatectl set-timezone Asia/Colombo```

* Set the IdP hostname, The public domain name of the IdP may be used in determined the entityID of the IdP.

(ATTENTION: Replace ```idp.YOUR-DOMAIN.ac.lk``` with your IdP Full Qualified Domain Name and <HOSTNAME> with the IdP hostname)

```vim /etc/hosts```

```
<YOUR SERVER IP ADDRESS> idp.YOUR-DOMAIN.ac.lk <HOSTNAME>
hostnamectl set-hostname <HOSTNAME>
```

* Install Ansible Package

```sudo apt install ansible```

For new installations download the ```bootstrap-v5.ini``` file as follows;

```
curl https://raw.githubusercontent.com/pakistan-identity-federation/shibboleth-idp4-installer/master/bootstrap-v4.ini > bootstrap-v4.ini
Edit the bootstrap-v4.ini file;
```

A description of each field is provided here and in the downloaded version of bootstrap-v5.in
```
vi bootstrap-v5.ini
```
You MUST review, configure and uncomment each field listed in the [main] section

If you have LDAP details you SHOULD also configure the [ldap] section

Running the installer

Download and prepare the bootstrap-v4.sh for execution using the following command;

```
curl https://raw.githubusercontent.com/pakistan-identity-federation/shibboleth-idp4-installer/master/bootstrap-v4.sh > bootstrap-v4.sh && chmod u+x bootstrap-v4.sh
```
Ensure that bootstrap-v5.ini is in the same directory used to download the bootstrap-v5.sh script.

Run the following command as root;

```./bootstrap-v5.sh```

The bootstrap-v5 process will now install and configure your server to operate as a Shibboleth IdP.

### Event logging

The installer provides a detailed set of information indicating the steps it has undertaken on your server. You MAY disregard this output if the process completes successfully.

For future review all installer output is logged to

```
/opt/shibboleth-idp-installer/activity.log
```

#### Check the IdP logs

The IdP writes its four log files into the directory ```/var/log/shibboleth-idp```. It may take a few minutes for the log files to appear the first time the IdP starts.

* Check idp-warn.log for any errors. This should only contain two Deprecation warnings that can be ignored.

* Check idp-process.log from any ERRORS and and verify the Servlet has started. You should find the following content near the end of the file.

#### Accessing the IdP

The IdP server should be responding the incoming requests. A web browser is simplest way to perform these tests but curl or wget will work.

The name of you IdP server should be the same as the value you supplied in the HOST_NAME value in bootstrap-v5.ini.

The IdP should NOT be listening on port 80.

    **http://idp.YOUR-DOMAIN.ac.lk**

The IdP should be listening on port 443. Attempting to access the root level of the IdP will redirect you to https://example.edu/ [Note: You will change this address later in the configuration].

https://idp.YOUR-DOMAIN.ac.lk
https://idp.YOUR-DOMAIN.ac.lk/idp
https://idp.YOUR-DOMAIN.ac.lk/idp/shibboelth

#### Errors during installation

If an error occurs, the logs prior to installer termination MUST be reviewed to understand the underpinning cause.

Generally the installer SHOULD be executed once.

After the initial execution you’ll receive an error if you try to run bootstrap.sh again.

You MUST NOT re-run bootstrap-v5.sh if the installation process completed but you made a simple mistake. e.g.

*   Mistyped config in the [main], [ldap] or [advanced] sections
If you force bootstrap-v4.sh to run again once initial installation has completed the action MAY be destructive.

#### Allowing the installer to run again

In general you will never need to re-run the bootstrap-v5.sh script after it has completed creating the /opt/shibboleth-v5-installer directory.

You should use the deploy or upgrade scripts instead.

If you must re-run bootstrap-v5.sh then you remove the lock file first. Note this will overwrite any previous installations.

```
    rm /root/.lock-idp-bootstrap-v5 && ./bootstrap-v5.sh
```

The bootstrap-v5 process will now start over and attempt to install and configure your server to operate as a Shibboleth IdP.

When Bootstrap-v5.sh completes

When the scripts completes the mariadb, jetty and the IdP should be running. The IdP probably will not be able to authenticate and there may be some errors in the Shibboleth log file ```/var/log/shibboleth-idp/idp-warn.log```. This is a good start but indicates that additional configuration is required.

#### Using the new Hello World feature

Using the new Hello World feature introduced at version 4.1. It should show the default login page. You can try entering your credentials and one of two outcomes will occur;

Successful login and you receive an Access Denied message. You need to configure the AccessByAdminUser adding your username to use. You will receive a list of your attributes as an Admin User.

Successful login and you receive an Uncaught Exception error message. This is caused be a requirement of the auEduPersonSharedToken generator. It requires the entityID of the IdP to be passed to it when generated a shared token for a user. Hello world does not provide this value. If the user already has a shared token it will be returned.

```https://idp.YOUR-DOMAIN.ac.lk/idp/profile/admin/hello```

#### Environmental data for your IdP in bootstrap-v5.ini

The following information is required by the IdP Installer and must be populated into the bootstrap-v5.ini file prior to running the installer.

* Host Name The public domain name of the IdP. May be used in determined the entityID of the IdP.

* Entity ID The unique technical name of the IdP. If migrating from an older IdP then its entity id should be used on the new IdP.

* Environment A determination of the PKIFED federation you wish to register your IdP within, being test or production.

* Organisation Name The human readable display name of your organisation

* Organisation base domain e.g. example.edu, used for the scope of user's scoped attributes

* Install base Where in the file system you want the IdP to be installed. The default is /opt

* Patch System Software If enabled, the operating system software will be updated every time the IdP is deployed, that is the command "yum update -y" will be executed. If you have your own system patching regime in place you can disable this feature. (Default is enabled.)

* eduGAIN enabled Additional configuration is enabled to allow the IdP to technically connect to eduGAIN. See eduGAIN for more information and how to join eduGAIN. (Default is enabled.)

* Local firewall enabled If enabled, firewalld will be enabled and configured on the server allowing. (Default is enabled.)

* Back-Channel enabled If enabled, the IdP will support back-channel requests. (Default is NOT enabled.)

#### How the Shibboleth IdP installer manages your configuration

IMPORTANT: All modifiable configuration is housed in the directory: 

```/<INSTALL_BASE>/shibboleth-idp5-installer/repository/assets/<HOST_NAME>```

By default ```<INSTALL_BASE> = /opt```

If you make configuration changes directly within /opt/shibboleth/shibboleth-idp, /opt/jetty or elsewhere your installation will become unsupported and you may have difficulties when upgrading.

#### Updating the Shibboleth IdP with customisations

##### Deploy

To deploy the changes you have made to the IdP run the deploy script.

```/opt/shibboleth-idp5-installer/repository/deploy```

Changes to your assets area will be deployed to the operational IdP and the IdP will be restated. There will be a short outage of the IdP as it is restarted, usually less than 2 minutes.

#### Actions undertaken during an deployment

The deploy process will perform the following:

Update underlying operating system packages to ensure any security issues are addressed

Apply any configuration changes made within the assets directory for:

* Shibboleth IdP
* Jetty

RESTART all dependant processes.

You MUST have a tested rollback plan in place before running an deployment to ensure any unanticipated changes can be reversed.

#### Apply configuration changes to the IdP

Deploy changes in your repository to your IdP

```/opt/shibboleth-idp5-installer/repository/deploy```

Restart the IdP (Jetty)

```systemctl restart idp```

