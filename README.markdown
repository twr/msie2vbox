# Introduction
msie2vbox creates VirtualBox machines from the Microsoft Application Compatibility VPC images that Microsoft provide for testing websites in Internet Explorer versions 6, 7 or 8.

The small application comprised of a bash script, the Python
BeautifulSoup (ver 3.0.7a) library, and a python script.

To run msie2vbox, just execute in a shell, passing in the required version of IE:

>`./msie2vbox.sh -v8`

 The Python script,
''getvpcurls.py'' is used to retrieve the direct download URL for the Application
Compatibility VM for the given version of Internet Explorer.  For example, to
get the download link for IE6, 

>`./getvpcurls.py ie6`

will return the appropriate URL.

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

>Usage: msie2vbox.sh [-h] -v{6,7,8} [-mN] [-nName] [-f path] [-d path] [-l path] -b  
>  
>OPTIONS:  
>  -h            Show this message  
>  -v {6,7,8}    Version to install  
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
* Default name of WinXPIE7
* Default install location of /home/max/ievpc/WinXPIE7
* Default name of Windows_XP_IE7_$(date +%s)
* Download the VPC image
  
>`./msie2vbox.sh -v 7 -d /home/max/Desktop/PROWin32.exe`

### IE8
* IE8
* Use 265Mb RAM
* Name of 'WInXPIE8'
* Boot on completion
* Download Image
* Download Intel Drivers

>`./msie2vbox -v 8 -m 256 -n WinXPIE8 -b`

## *Inconsistencies / Manual Steps
* The VM is configured without USB support
* The VM is configured without audio
* Update the drivers for the ethernet device with those provided on the pre-mounted D:\ drive
* Validate the VM with Microsoft
* Install the Virtual Box Guest Additions
* Disable 'battery' devices

## To Do
* Remove any existing VM with the same name; failure to do so may result in unexpected behaviour
  * Detach storage devices
  * Unregister the VM
  * Remove storage devices
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

