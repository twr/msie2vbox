#!/bin/bash
#
# Max Manders
# max@maxmanders.co.uk
# http://maxmanders.co.uk
#
# 2011-03-06
#
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a
# copy of this license, visit
# http://creativecommons.org/licenses/by-nc-sa/3.0/
# or send a letter to Creative Commons, 171 Second Street, Suite 300,
# San Francisco, California, 94105, USA.
#

## Logging / Variables ########################################################
SCRIPT_NAME=$(basename $0)
DIR_NAME=$(dirname ${SCRIPT_NAME})
TMP_DIR="/tmp/${SCRIPT_NAME}.$$.tmp"
LOG="${TMP_DIR}/${SCRIPT_NAME}.log"
ERR="${TMP_DIR}/${SCRIPT_NAME}.err"
GET_URLS="${DIR_NAME}/getvpcurls.py"
INTEL_URL="http://downloadmirror.intel.com/18717/eng/PROWin32.exe"
INTEL_ISO="${TMP_DIR}/INTEL_DRIVERS.ISO"
INTEL_DIR="${TMP_DIR}/INTEL_DRIVERS"

cd ${DIR_NAME}

mkdir -p ${TMP_DIR}
touch ${LOG}
touch ${ERR}

# The version of IE to download/install
IE_VER=""
# The path to a local IE VPC image.
VPC_PATH=""
# The path to the extracted VHD image.
VHD_IMAGE=""
# RAM to allocate to the VM
RAM="192"
# Name to give to the VM.
VM_NAME=""
# Path to Intel Drivers.
INTEL_PATH=""
# Path to store VMs.
VM_LOC=""
# Whether to auto boot the VM
AUTO_BOOT=0
# Rate limit wget
RATE_LIMIT=""

## Functions ##################################################################
# Print script usage.
usage() {
cat << EOF
This program can be used to create a new VirtualBox machine from a Microsoft
Application Compatibility VPC image.  Since the original Microsoft images
are built for Microsoft Virtual PC, there are a few 'inconsistencies'*.

The VMs can be installed to a specific location supplied by the '-l <path>' arguement
or by default to ~/ievpc/.  The VM will be named based on the supplied version of IE,
e.g. XPSP3_IE6, or by the name supplied by the '-n <name>' arguement.

Each VM will default to 192M RAM; this can be overridden with the '-mN' arguement where
'N' is the desired amount of RAM to allocate, in megabytes.  This program will
download the appropriate VPC image, but you can specify the path to a local VPC image
using the '-f <path>' arguement.

The VMs require the Intel 82540EM network adapter.  Drivers for this are downloaded and
built into a ready-mounted ISO when the VM is booted.  You will need to manually
update the network adapter drivers before verifying your VM with Microsoft.

By default, the VM will not boot when this script is complete.  Use the '-b' arguement
to boot the VM.

Usage: ${SCRIPT_NAME} [-h] -v{6,7,8} [-mN] [-nName] [-f path] [-d path] [-l path] -b

OPTIONS:
  -h            Show this message
  -v {6,7,8}    Version to install
  -m            RAM to allocate (in MB)
  -n            Name of the Virtual Machine
  -f            Path to existing VPC image
  -d            Path to Intel Drivers EXE
  -l            Path to store VHD files
  -b            Boot VM on completion.
EOF
}

# Empty the tmp directory and exit.
clean_and_exit() {
  if [ ${TMP_DIR} ]; then
    rm -fr $TMP_DIR
  fi
  exit 1
}

# Check for unmet dependencies.
check_dependencies() {
  is_vbox_installed=$(which vboxmanage)
  if [ -z ${is_vbox_installed} ]; then
    echo "Missing: VirtualBox not installed." >> ${ERR}
  fi

  is_7zip_installed=$(which 7z)
  if [ -z ${is_7zip_installed} ]; then
    echo "Missing: 7-Zip not installed." >> ${ERR}
  fi

  is_wget_installed=$(which wget)
  if [ -z ${is_wget_installed} ]; then
    echo "Missing: wget not installed." >> ${ERR}
  fi

  is_mkisofs_installed=$(which mkisofs)
  if [ -z ${is_mkisofs_installed} ]; then
    echo "Missing: mkisofs not installed." >> ${ERR}
  fi
}

# Get a VPC image from somewhere.
get_image() {
  # If we haven't specified a local VPC location, we need to retrieve the
  # appropriate image from the web.
  if [ -z ${VPC_PATH} ]; then
    echo "Downloading VPC image..."
    if [ -n "${RATE_LIMIT}" ]; then
      wget $(${GET_URLS} ie${IE_VER}) --limit-rate=${RATE_LIMIT} -P ${TMP_DIR}
    else
      wget $(${GET_URLS} ie${IE_VER}) -P ${TMP_DIR}
    fi
  else
    cp ${VPC_PATH} ${TMP_DIR}/
  fi
  # We've either downloaded a VPC image with wget or specified the location
  # to a local image in the command line.  Let's make sure either way, the
  # file is copied to the same place.
  VPC_PATH="${TMP_DIR}/XPSP3-IE${IE_VER}.EXE"

  # Extract the image from the EXE
  7z x ${VPC_PATH} -o${TMP_DIR}/ >/dev/null 2>&1

  VHD_IMAGE="${TMP_DIR}/IE${IE_VER}Compat.vhd"
}

prepare_intel_drivers() {
  # If we've installed a VM before using the script, the INTEL_DRIVERS.ISO
  # might already exist in the VM directory.
  if [ ! -f "${VM_LOC}/INTEL_DRIVERS/INTEL_DRIVERS.ISO" ]; then
    # If we haven't specified a local path, we need to retrieve the
    # drivers from the web.
    if [ -z ${INTEL_PATH} ]; then
      echo "Downloading Intel drivers..."
      if [ -n "${RATE_LIMIT}" ]; then
        wget ${INTEL_URL} --limit-rate=${RATE_LIMIT} -P ${TMP_DIR}
      else
        wget ${INTEL_URL} -P ${TMP_DIR}
      fi
    else
      cp ${INTEL_PATH} ${TMP_DIR}/
    fi
    mkdir -p ${INTEL_DIR}
    7z x ${TMP_DIR}"/PROWin32.exe" -o${INTEL_DIR} > /dev/null 2>&1
    mkisofs -o ${INTEL_ISO} ${INTEL_DIR} > /dev/null 2>&1
    mv ${INTEL_ISO} "${VM_LOC}/INTEL_DRIVERS/"
  fi
}

# Configure the VM
prepare_vm() {
  # If we haven't passed in a name, create one based on the current timestamp.
  if [ -z ${VM_NAME} ]; then
    VM_NAME="Windows_XP_IE${IE_VER}_$(date +%s)"
  fi

  # If we havem't passed in an installation directory, then default to
  # ~/ievpc/.
  if [ -z ${VM_LOC} ]; then
    VM_LOC="${HOME}/ievpc"
  fi

  mkdir -p "${VM_LOC}/${VM_NAME}"
  mv ${VHD_IMAGE} "${VM_LOC}/${VM_NAME}/"
  VHD_IMAGE="${VM_LOC}/${VM_NAME}/IE${IE_VER}Compat.vhd"
  mkdir -p "${VM_LOC}/INTEL_DRIVERS"

  # We need to make a mountable image containing the VM Intel drivers.
  prepare_intel_drivers

  # Name and register an empty Windows XP VM.
  vboxmanage createvm --name ${VM_NAME} --ostype WindowsXP --register

  # Create the IDE controller.
  vboxmanage storagectl ${VM_NAME} --name "IDEController" --add ide --controller PIIX4

  # Set a new/unique UUID for this disk.
  vboxmanage internalcommands sethduuid ${VHD_IMAGE}

  # Attach the VHD.
  vboxmanage storageattach ${VM_NAME} --storagectl IDEController --port 0 --device 0 --type hdd --medium ${VHD_IMAGE}

  # Attach the ISO.
  vboxmanage storageattach ${VM_NAME} --storagectl IDEController --port 0 --device 1 --type dvddrive --medium "${VM_LOC}/INTEL_DRIVERS/INTEL_DRIVERS.ISO"

  # Set boot priorities.
  vboxmanage modifyvm ${VM_NAME} --boot1 disk --boot2 none --boot3 none --boot4 none

  # Set other hardware.
  vboxmanage modifyvm ${VM_NAME} --vram 32 --memory ${RAM} --nic1 nat --nictype1 82540EM --cableconnected1 on --audio none --usb off
}

# Main
main() {
  # Check dependencies and exit with error if there are any unmet dependencies.
  check_dependencies
  if [ -s ${ERR} ]; then
    cat ${ERR}
    clean_and_exit
  fi

  # Get the VPC image into a known location, either with wget or copying
  # a local image.
  get_image
  
  # Configure the VM.
  prepare_vm

  # Start VM.
  if [ "${AUTO_BOOT}" -eq "1" ]; then
    vboxmanage startvm "${VM_NAME}"
  fi

  clean_and_exit
}

# Clean up any left overs.
rm -fr /tmp/${SCRIPT_NAME}.*.tmp

if [ "$#" -eq "0" ]; then
  usage
  exit 1
fi

# Process command line args.
while getopts "hbv:m:n:f:d:l:r:" OPTION; do
  case ${OPTION} in
    h)
      usage
      exit
      ;;
    v)
      IE_VER=${OPTARG}
      ;;
    m)
      RAM=${OPTARG}
      ;;
    n)
      VM_NAME=${OPTARG}
      ;;
    f)
      VPC_PATH=${OPTARG}
      ;;
    d)
      INTEL_PATH=${OPTARG}
      ;;
    l)
      VM_LOC=${OPTARG}
      ;;
    b)
      AUTO_BOOT=1
      ;;
    r)
      RATE_LIMIT=${OPTARG}
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

# Run main()
main
