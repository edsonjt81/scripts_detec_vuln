# Vulnerability Detection Scripts

[![Travis CI test status](https://img.shields.io/travis/skontar/cvss/master.svg)](https://travis-ci.org/RedHatProductSecurity/vulnerability-detection-scripts)

This repository contains vulnerability detection scripts that test whether a Red Hat Enterprise Linux system is vulnerable to a specific security vulnerability, usually those documented in [Red Hat Vulnerability Response articles](https://access.redhat.com/security/vulnerabilities).


## Supported Systems and Bash Versions

Currently, the detection scripts are developed for Red Hat Enterprise Linux 6-8 (we still maintain Bash v3.2 compatibility, though).

They should work on all direct derivatives of RHEL (e.g. CentOS), but unless it is possible to reproduce the issue on Red Hat Enterprise Linux we cannot guarantee that the scripts will be supported on other systems.


## Support Timeframe

The detection scripts are fully supported for two months after a vulnerability becomes public.
After this time, only important bug fixes will be made.


## Limitations

For compatibility reasons, the detection scripts have to be compatible with Bash v3.2 (early RHEL 5) and later.
This means that some of the features available in newer Bash versions cannot be used (e.g. `readarray`).

Some of the scripts also contain a large RPM version list to check the installed RPMs against.
Because Red Hat [backports security patches](https://access.redhat.com/security/updates/backporting) and there are different update streams, a simple version comparison is often not possible.
For a more detailed explanation see [this blog post](https://access.redhat.com/blogs/766093/posts/2998921).


## Basic Script Structure

Vulnerability detection scripts are meant to be self-contained.
All utility functions from our library need to be copied inside the script.

Newer scripts also follow the following structure:
* Check requirements for detection
* Parse facts and store them in variables
* Draw conclusions and store them in different variables
* Present results based on facts and conclusions

All scripts support the `--debug` option to print out the state of the variables.


## Testing

All scripts are analyzed using [Shellcheck](https://github.com/koalaman/shellcheck) and tested using [Bash Automated Testing System](https://github.com/sstephenson/bats).
