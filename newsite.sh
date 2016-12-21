#------------------------------------------------------------------
#
# Adapted from https://github.com/alanauckland86/MAMP-newsite-setup-script-/blob/master/newsite.sh
#
# To run type: sudo sh newsite.sh
#
#------------------------------------------------------------------

# 1 Get the name for the new site
#================================
read -p "New site name: " SITE


# 2 Set up variables
#===================
# 2.1 Determine account under which this site will be set up
if [ $SUDO_USER ]
	then LOGGEDINUSER=$SUDO_USER
	else LOGGEDINUSER=`whoami`
fi

# 2.2 Get the document root and append site name to create path to new directory
DOCROOT=$(grep "DocumentRoot \"" /Applications/MAMP/conf/apache/httpd.conf) # Find line with DocumentRoot in httpd.conf
DOCROOT=$(echo "${DOCROOT##* }" | tr -d '"') # Isolate DocumentRoot path and strip off quotemarks
SITEPATH="${DOCROOT}/${SITE}"

# 2.3 Path to httpd-vhosts.conf
VHOSTSFILE="/Applications/MAMP/conf/apache/extra/httpd-vhosts.conf"

# 2.4 TLD (edit this if you want a different TLD)
TLD="local"

# 2.5 Path to the test file that will be created
TESTFILE="${SITEPATH}/index.html"


# 3 Make new directory and change owner (so not owned by 'root')
#======================================
mkdir $SITEPATH
chown $LOGGEDINUSER $SITEPATH


# 4 Add new entry in /etc/hosts and flush DNS cache
#==================================================
echo "127.0.0.1\t${SITE}.${TLD}" >> /etc/hosts
dscacheutil -flushcache


# 5 Add new virtual host to http-vhosts.conf
#===========================================
echo "\n<VirtualHost *:80>" >> $VHOSTSFILE
echo "\tServerAdmin webmaster@${SITE}.${TLD}" >> $VHOSTSFILE
echo "\tDocumentRoot \"${SITEPATH}\"" >> $VHOSTSFILE
echo "\tServerName ${SITE}.${TLD}" >> $VHOSTSFILE
echo "\tErrorLog \"/Applications/MAMP/logs/${SITE}-error.log\"" >> $VHOSTSFILE
echo "\tCustomLog \"/Applications/MAMP/logs/${SITE}-access.log\" common" >> $VHOSTSFILE
echo "</VirtualHost>" >> $VHOSTSFILE


# 6 Create index.html file for testing
#=====================================
echo "<!DOCTYPE html>\n<html>\n<head>\n<title>Test page</title>\n</head>\n" >> $TESTFILE
echo "<body>\n<h1>TEST PAGE</h1>\n<p>Hooray - your site called ${SITE} is working!</p>\n</body>\n</html>" >> $TESTFILE
chown $LOGGEDINUSER $TESTFILE # so owned by user running sudo rather than owned by 'root'


# 7 Restart Apache
#=================
/Applications/MAMP/bin/apache2/bin/apachectl restart;


# 8 Prompt user to test
#======================
echo "To confirm that the new site is working open web browser and type ${SITE}.${TLD}/ in address bar."
