# idmap Module

## Overview

The **idmap** configures the idmapper for NFSv4 domains.  If it has not already been installed the nfs utils OS package is installed as this contains the idmapper

##Configuration


###`nfsv4_domain`

The local NFSv4 domain name.  If a value is set then the idmapper is configured with this domain, if not nothing is done **Default: no value** (this option can be overwritten by a host level entry)

###`idmap_nobody_user` 

Local user name to be used when a mapping cannot be completed  **Default: nobody**

###`idmap_verbosity`

The verbosity level of debugging messages **Default: 0**

###`idmap_translation_method`

A comma-separated, ordered list of mapping methods (plug-ins) to use when mapping between NFSv4 names and local IDs **Default: nsswitch**

###`config_file`

The location of the idmapper configuration file **Default: /etc/idmapd.conf'**

##Hiera Examples:

        #set nfsv4 domain
        idmap::nfsv4_domain: 'mydomain.com'

## Dependencies

This module has no dependencies.