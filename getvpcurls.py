#!/usr/bin/env python
#
# Max Manders
# max@maxmanders.co.uk
# http://maxmanders.co.uk
#
# 2011-03-06
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


from BeautifulSoup import BeautifulSoup
import urllib
import re
import sys

def usage():
  print 'Usage: ./getvpcurls [ie6,ie7,ie8]'
  sys.exit()

if len(sys.argv) < 2:
  usage()

browserVersion = ''

if sys.argv[1].find('6') > 0:
  browserVersion = 'IE6'
elif sys.argv[1].find('7') > 0:
  browserVersion = 'IE7'
elif sys.argv[1].find('8') > 0:
  browserVersion = 'IE8'
else:
  usage()

downloadLink = "http://www.microsoft.com/downloads/en/details.aspx?FamilyId=21EABB90-958F-4B64-B5F1-73D0A413C8EF&displaylang=en"
linkHandle = urllib.urlopen(downloadLink)
linkContent = linkHandle.read()

soup = BeautifulSoup(linkContent)
downloadLinks = soup.findAll('a', {'class': "download-btn"})
for downloadLink in downloadLinks:
  theLink = downloadLink['href']
  pattern = re.compile(r'^.*&u=(.*XPSP3\-%s.*)$' % (browserVersion))
  matches = pattern.findall(theLink)
  if matches:
    print urllib.unquote(matches[0])
