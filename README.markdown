# Introduction
msie2vbox is a small application comprised of a bash script, the Python
BeautifulSoup (ver 3.0.7a) library, and a python script.  The Python script,
''getvpcurls.py'' is used to retrieve the direct download URL for the Application
Compatibility VM for the given version of Internet Explorer.  For example, to
get the download link for IE6, 

>`./getvpcurls.py ie6`

will return the approrpiate URL.

This script is called from within msie2vbox.sh, which does the majority of the work
including checking for dependencies, downloading IE VPC images and Intel
NIC drivers etc.

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

## License 
This work is licensed under the Creative Commons
Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a
copy of this license, visit
http://creativecommons.org/licenses/by-nc-sa/3.0/
or send a letter to Creative Commons, 171 Second Street, Suite 300,
San Francisco, California, 94105, USA.


