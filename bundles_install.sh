#!/bin/bash

export http_proxy=http://proxy-us.intel.com:911
export https_proxy=http://proxy-us.intel.com:911
export ftp_proxy=http://proxy-us.intel.com:911
export socks_proxy=http://proxy-us.intel.com:1080
export no_proxy=intel.com,.intel.com,10.0.0.0/8,192.168.0.0/16,localhost,127.0.0.0/8,134.134.0.0/16


clr_bundle_add storage-utils
clr_bundle_add os-testsuite
