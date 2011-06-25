# Introduction
msie2vbox creates VirtualBox machines from the Microsoft Application Compatibility VPC images that Microsoft provide for testing websites in Internet Explorer versions 6, 7 or 8.  The application only supports downloading and installing the Windows XP VPC image.  This image defaults to IE6 but contains shortcuts to update to IE7 or IE8.  It is recommended that a local copy of the downloaded VPC image be kept to make creating subsequent VirtualBox VMs quicker.

To run msie2vbox, just execute in a shell.

>`./msie2vbox.sh`

## Dependencies
* [VirtualBox](http://www.virtualbox.org/)
* [7-Zip](http://www.7-zip.org/download.html) (Available in most package managers as "p7zip")
* [wget](http://www.gnu.org/software/wget/)
* [mkisofs](http://freshmeat.net/projects/mkisofs/)

## Options
This program can be used to create a new VirtualBox machine from a Microsoft
Application Compatibility VPC image.  Since the original Microsoft images
are built for Microsoft Virtual PC, there are a few 'inconsistencies'*.

The VMs can be installed to a specific location supplied by the '-l <path>' arguement
or by default to ~/ievpc/.  The VM will be named based on the supplied version of IE,
e.g. 'Windows_XP_IE7_$(date +%s)', or by the name supplied by the '-n <name>' arguement.

Each VM will default to 192M RAM; this can be overridden with the '-mN' arguement where
'N' is the desired amount of RAM to allocate, in megabytes.  This program will
download the appropriate VPC image, but you can specify the path to a local VPC image
using the '-f <path>' arguement.

The VMs require the Intel 82540EM network adapter.  Drivers for this are downloaded and
built into a ready-mounted ISO when the VM is booted.  You will need to manually
update the network adapter drivers before verifying your VM with Microsoft.  If you install
a VM into a location that already has the Intel Drivers

>`/path/to/INTEL_DRIVERS/INTEL_DRIVERS.ISO`

then this program will use the existing ISO.

By default, the VM will not boot when this script is complete.  Use the '-b' arguement
to boot the VM.

>Usage: msie2vbox.sh [-h] [-mN] [-nName] [-f path] [-d path] [-l path] -b  
>  
>OPTIONS:  
>  -h            Show this message  
>  -m            RAM to allocate (in MB)  
>  -n            Name of the Virtual Machine  
>  -f            Path to existing VPC image  
>  -d            Path to Intel Drivers EXE  
>  -l            Path to store VHD files  
>  -b            Boot VM on completion.  
  

## Examples
### IE 7
* IE 7
* Existing local copy of Intel drivers in /home/max/Desktop/PROWin32.exe
* Default 192Mb RAM
* Default name of Windows_XP_IE7_$(date +%s)
* Download the VPC image
  
>`./msie2vbox.sh -d /home/max/Desktop/PROWin32.exe`

After installation, you will need to use the desktop shortcut to update the machine to IE7.

### IE8
* IE8
* Use 265Mb RAM
* Name of 'WinXPIE8'
* Boot on completion
* Specify path to existing VPC executable
* Download Intel Drivers

>`./msie2vbox -m 256 -f /path/to/Windows_XP_IE6.exe -n WinXPIE8 -b`

After installation, you will need to use the desktop shortcut to update the machine to IE8.

## *Inconsistencies / Manual Steps
* The VM is configured without USB support
* The VM is configured without audio
* Update the drivers for the ethernet device with those provided on the pre-mounted D:\ drive
* Validate the VM with Microsoft
* Install the Virtual Box Guest Additions
* Disable 'battery' devices

## To Do
* Investigate use of registry files or other some alternative method to automate driver installation
* Automated installation of Vbox Guest Additions

## License 
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

