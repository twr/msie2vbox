#!/bin/bash
#
#

## Logging / Variables ########################################################
SCRIPT_NAME=$(basename $0)
TMP_DIR="/tmp/${SCRIPT_NAME}.$$.tmp"
LOG="${TMP_DIR}/${SCRIPT_NAME}.log"
ERR="${TMP_DIR}/${SCRIPT_NAME}.err"

mkdir -p ${TMP_DIR}
touch ${LOG}
touch ${ERR}

## Functions ##################################################################

usage() {
cat << EOF
This program can be used to create a new VirtualBox machine from a Microsoft
Application Compatibility VPC image.  By default this script will destroy any
existing VM for the given version of IE; this can be changed by specifying a
different name using the '-n <name>' option.

Usage: ${SCRIPT_NAME} [options]

OPTIONS:
  -h            Show this message
  -v {6,7,8}    Version to install
  -m            RAM to allocate (in MB)
  -n            Name of the Virtual Machine
  -f            Path to existing VPC image
EOF
}

clean_and_exit() {
  rm -fr $TMP_DIR
  exit 1
}

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
}

main() {
  check_dependencies
  if [ -s ${ERR} ]; then
    cat ${ERR}
    clean_and_exit
  fi

  if [ -z ${VPC_PATH} ]; then

}

while getopts "hv:f:" OPTION; do
  case ${OPTION} in
    h)
      usage
      ;;
    v)
      IE_VER=${OPTARG}
      ;;
    f)
      VPC_PATH=${OPTARG}
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

main
