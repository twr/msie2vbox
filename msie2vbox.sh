#!/bin/bash
#
# Max Manders
# max@maxmanders.co.uk
# http://maxmanders.co.uk
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

SCRIPT_NAME=$(basename $0)
DIR_NAME=$(dirname $0)
TMP_DIR="/tmp/${SCRIPT_NAME}.$$.tmp"
INTEL_URL="http://downloadmirror.intel.com/18717/eng/PROWin32.exe"
INTEL_ISO="${TMP_DIR}/INTEL_DRIVERS.ISO"
INTEL_DIR="${TMP_DIR}/INTEL_DRIVERS"
DOWNLOAD_URL="http://download.microsoft.com/download/B/7/2/B72085AE-0F04-4C6F-9182-BF1EE90F5273/Windows_XP_IE6.exe"

cd ${DIR_NAME}

mkdir -p ${TMP_DIR}

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
# Path to store downloaded images
VM_LOC="${HOME}/ievpc"
# Whether to auto boot the VM
AUTO_BOOT=0
# Rate limit curl
RATE_LIMIT=""
# Directory to Create Virtualbox VM
VM_STORE=""

## Functions ##################################################################
usage() {

cat << EOF
This program can be used to create a new VirtualBox machine from a Microsoft
Application Compatibility VPC image.  Since the original Microsoft images
are built for Microsoft Virtual PC, there are a few 'inconsistencies'*.

The VMs can be installed to a specific location supplied by the '-l <path>' argument
or by default to ~/vbox/.

Each VM will default to 192M RAM; this can be overridden with the '-mN' argument where
'N' is the desired amount of RAM to allocate, in megabytes.  This program will
download the appropriate VPC image, but you can specify the path to a local VPC image
using the '-f <path>' arguement.  This latter option is more practical once an initial
image has been downloaded to save time and bandwidth.

The VMs require the Intel 82540EM network adapter.  Drivers for this are downloaded and
built into a ready-mounted ISO when the VM is booted.  You will need to manually
update the network adapter drivers before verifying your VM with Microsoft.

By default, the VM will not boot when this script is complete.  Use the '-b' arguement
to boot the VM.

Usage: ${SCRIPT_NAME} [-h] [-mN] [-nName] [-f path] [-d path] [-l path] -b

OPTIONS:
  -h            Show this message
  -m            RAM to allocate (in MB)
  -n            Name of the Virtual Machine
  -f            Path to existing VPC image
  -d            Path to Intel Drivers EXE
  -l            Path to store VHD files
  -b            Boot VM on completion.
EOF
}

clean_and_exit() {

  rm -fr ${TMP_DIR}
  exit 1;
}

check_dependencies() {

  echo "Checking Dependencies..."

  is_vbox_installed=$(which vboxmanage)
  if [ -z ${is_vbox_installed} ]; then
    echo "ERROR: Missing: VirtualBox not installed."
    exit 1
  fi

  is_7zip_installed=$(which 7z)
  if [ -z ${is_7zip_installed} ]; then
    echo "ERROR: Missing: 7-Zip not installed."
    exit 1
  fi

  is_curl_installed=$(which curl)
  if [ -z ${is_curl_installed} ]; then
    echo "ERROR: Missing: curl not installed."
    exit 1
  fi

  is_mkisofs_installed=$(which mkisofs)
  if [ -z ${is_mkisofs_installed} ]; then
    echo "ERROR: Missing: mkisofs not installed."
    exit 1
  fi
}

get_image() {

  # If we haven't specified a local VPC/EXE location, we need to retrieve the
  # appropriate image from the web.
  if [ -z ${VPC_PATH} ]; then
    echo "Downloading VPC image..."
    VPC_PATH="${VM_LOC}/Windows_XP_IE6"

    if [ -n "${RATE_LIMIT}" ]; then
      curl --verbose -L ${DOWNLOAD_URL} --limit-rate=${RATE_LIMIT} -o ${VPC_PATH}
    else
      curl --verbose -L ${DOWNLOAD_URL} -o ${VPC_PATH}
    fi
  fi

  VHD_IMAGE_NAME=`7z l -slt ${VPC_PATH} | egrep --color=never "^Path = [^.]*\.vhd$" | sed -e 's/Path = \(.*\)$/\1/'`

  echo "VHD image from exe is called ${VHD_IMAGE_NAME}"

  # Extract the image from the EXE
  echo "Extracting VHD file ${VHD_IMAGE_NAME}..."
  7z x ${VPC_PATH} -o${VM_LOC}/ -y >/dev/null 2>&1

  VHD_IMAGE="${VM_LOC}/${VHD_IMAGE_NAME}"
}

prepare_intel_drivers() {

  echo "Preparing Intel drivers..."

  # If we've installed a VM before using the script, the INTEL_DRIVERS.ISO
  # might already exist in the VM directory.
  if [ ! -f "${VM_LOC}/INTEL_DRIVERS/INTEL_DRIVERS.ISO" ]; then
    # If we haven't specified a local path, we need to retrieve the
    # drivers from the web.
    if [ -z ${INTEL_PATH} ]; then
      echo "Downloading Intel drivers..."
      if [ -n "${RATE_LIMIT}" ]; then
        curl --verbose -L ${INTEL_URL} --limit-rate=${RATE_LIMIT} -o "/tmp/PROWin32.exe"
      else
        curl --verbose -L ${INTEL_URL} -o "/tmp/PROWin32.exe"
      fi
    fi
    mkdir -p ${INTEL_DIR}
    echo "Extracting Intel drivers from PROWin32.exe."
    7z x ${TMP_DIR}"/PROWin32.exe" -o${INTEL_DIR} -y > /dev/null 2>&1
    mkisofs -o ${INTEL_ISO} ${INTEL_DIR} > /dev/null 2>&1
    mkdir -p "${VM_LOC}/INTEL_DRIVERS"
    cp ${INTEL_ISO} "${VM_LOC}/INTEL_DRIVERS/"
  else
    echo "Intel drivers already present in ${VM_LOC}..."
  fi
}

prepare_vm() {

  # If we haven't passed in a name, create one based on the current timestamp.
  if [ -z "${VM_NAME}" ]; then
    VM_NAME="Windows_XP_IE_$(date +%s)"
    echo "No VM name given, setting name as ${VM_NAME}."
  fi

  # If we havem't passed in an installation directory, then default to
  # ~/vbox/.
  if [ -z ${VM_STORE} ]; then
    VM_STORE="${HOME}/vbox"
    echo "No VM location given, setting location as ${VM_STORE}."
  fi

  # Delete and unregister any existing VM with the same name.
  if [ -d "${VM_STORE}/${VM_NAME}"  ]; then
    echo "A VM with the given name already exists."
    while true; do
      read -p "Continue, replacing this VM?[y/n]" ans
      case ${ans} in
        [Yy]* )
          is_vm_registered=$(vboxmanage list vms | grep --color=never ${VM_NAME})

          if [ -n "${is_vm_registered}" ]; then
            vboxmanage storagectl ${VM_NAME} --name="IDEController" --controller="PIIX4" --remove
            vboxmanage unregistervm ${VM_NAME} --delete
          fi

          rm -fr ${VM_STORE}/${VM_NAME}
          break
          ;;
        [Nn]* )
          clean_and_exit
          break
          ;;
        * )
          echo "Please answer 'Y' or 'N'."
          ;;
      esac
    done
  fi

  mkdir -p "${VM_STORE}/${VM_NAME}"
  cp "${VHD_IMAGE}" "${VM_STORE}/${VM_NAME}/"
  VHD_IMAGE="${VM_STORE}/${VM_NAME}/${VHD_IMAGE_NAME}"
  mkdir -p "${VM_STORE}/INTEL_DRIVERS"

  # We need to make a mountable image containing the VM Intel drivers.
  prepare_intel_drivers

  # Name and register an empty Windows XP VM.
  echo "Creating and registering VM..."
  vboxmanage createvm --name ${VM_NAME} --ostype WindowsXP --register

  # Create the IDE controller.
  echo "Creating and attaching IDE controller..."
  vboxmanage storagectl ${VM_NAME} --name "IDEController" --add ide --controller PIIX4

  # Set a new/unique UUID for this disk.
  echo "Resetting UUID for VM..."
  vboxmanage internalcommands sethduuid "${VHD_IMAGE}"

  # Clone VHD to VDI and attach
  # See http://forums.virtualbox.org/viewtopic.php?f=2&t=43940#p197795
  echo "Attaching VHD/VDI to IDE controller..."
  vboxmanage clonehd "${VHD_IMAGE}" "${VM_STORE}/${VM_NAME}/${VM_NAME}.vdi" --format=VDI
  rm -f ${VHD_IMAGE}
  VHD_IMAGE=${VM_STORE}/${VM_NAME}/${VM_NAME}.vdi
  vboxmanage storageattach ${VM_NAME} --storagectl IDEController --port 0 --device 0 --type hdd --medium "${VHD_IMAGE}"

  # Attach the ISO.
  echo "Attaching Intel Drivers ISO..."
  vboxmanage storageattach ${VM_NAME} --storagectl IDEController --port 0 --device 1 --type dvddrive --medium "${VM_LOC}/INTEL_DRIVERS/INTEL_DRIVERS.ISO"

  # Set boot priorities.
  echo "Configuring boot priorities..."
  vboxmanage modifyvm ${VM_NAME} --boot1 disk --boot2 none --boot3 none --boot4 none

  # Set other hardware.
  echo "Configuring VM hardware..."
  vboxmanage modifyvm ${VM_NAME} --vram 32 --memory ${RAM} --nic1 nat --nictype1 82540EM --cableconnected1 on --audio none --usb off

}

main() {

  check_dependencies
  get_image
  prepare_vm

  # Start VM.
  if [ "${AUTO_BOOT}" -eq "1" ]; then
    echo "Launching VM..."
    vboxmanage startvm "${VM_NAME}"
  fi

  clean_and_exit
}

# Process command line args.
while getopts "hbv:m:n:f:d:l:r:" OPTION; do
  case ${OPTION} in
    h)
      usage
      exit
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
      VM_STORE=${OPTARG}
      ;;
    b)
      AUTO_BOOT=1
      ;;
    r)
      RATE_LIMIT=${OPTARG}
      ;;
  esac
done

trap clean_and_exit INT TERM EXIT

# Run main()
main

