# $1 - Ip address of server 
# Set up a new Ubuntu 16 server you can afford to lose
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "Identity file: .ssh/id_rsa not found! Generate a key with ssh-keygen"
  exit
fi

cat <<ENDCAT > /tmp/serverSetUpSshd.sh
cat <<ENDSSH > /etc/ssh/sshd_config
# AppaAppsPhotoApp configuration
# See the sshd_config(5) manpage for details

# What ports, IPs and protocols we listen for
Port 22
# Use these options to restrict which interfaces/protocols sshd will bind to
#ListenAddress ::
#ListenAddress 0.0.0.0
Protocol 2
# HostKeys for protocol version 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
#Privilege Separation is turned on for security
UsePrivilegeSeparation yes

# Lifetime and size of ephemeral version 1 server key
KeyRegenerationInterval 3600
ServerKeyBits 1024

# Logging
SyslogFacility AUTH
LogLevel INFO

# Authentication:
LoginGraceTime 120
PermitRootLogin without-password
StrictModes yes

RSAAuthentication yes
PubkeyAuthentication yes
#AuthorizedKeysFile     %h/.ssh/authorized_keys

# Don't read the user's ~/.rhosts and ~/.shosts files
IgnoreRhosts yes
# For this to work you will also need host keys in /etc/ssh_known_hosts
RhostsRSAAuthentication no
# similar for protocol version 2
HostbasedAuthentication no
# Uncomment if you don't trust ~/.ssh/known_hosts for RhostsRSAAuthentication
#IgnoreUserKnownHosts yes

# To enable empty passwords, change to yes (NOT RECOMMENDED)
PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no
# Kerberos options
#KerberosAuthentication no
#KerberosGetAFSToken no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes

X11Forwarding no
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no                                          Perl Commands 1 = F8
                                                      Perl Commands 2 = F9
#MaxStartups 10:30:60                                 Independent Commands = F6
#Banner /etc/issue.net
# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

Subsystem sftp /usr/lib/openssh/sftp-server

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM yes

# Allow only root access
AllowUsers root
ENDSSH

cat <<ENDLOCALE > /etc/default/locale
LANG="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
ENDLOCALE
echo "Packages"
apt-get -y update

echo "Apt"
apt-get -y install build-essential mc awscli zip unzip python-pip apache2 imagemagick openjdk-8-jdk curl

echo "Cpan"
echo -n 'yes\n' | cpan -iT Module::Build Android::Build Aws::Polly::Select Data::Dump Data::GUID CGI Data::Table::Text File::Copy GitHub::Crud Google::Translate::Languages ISO::639 JSON Storable Unicode::UTF8 Data::Send::Local  Digest::SHA1 Test2::Bundle::More

echo "AWS CLI"
pip install awscli --system

echo "Android"
mkdir -p /home/phil//Android/sdk/

echo "Build Tools"
rm /home/phil/buildTools.zip  2>/dev/null
curl -L "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip" -o /home/phil/buildTools.zip
cd /home/phil/Android/sdk/ && unzip -qo /home/phil/buildTools.zip

echo "Platform Tools"
rm /home/phil/platformTools.zip  2>/dev/null
curl -L "https://dl.google.com/android/repository/platform-tools-latest-linux.zip" -o /home/phil/platformTools.zip
(cd /home/phil/Android/sdk/ && unzip -qo /home/phil/platformTools.zip)

echo "Android SDK"
touch /root/.android/repositories.cfg
echo -e 'y
' | /home/phil/Android/sdk/tools/bin/sdkmanager 'platforms;android-25'  'build-tools;25.0.3'

echo "Apache"
a2enmod cgid
service apache2 restart

echo "Clean up"
rm /home/phil/buildTools.zip /home/phil/platformTools.zip /tmp/serverSetUpSshd.sh

echo "Create folders"
mkdir -p /home/phil/AppaAppsPhotoApp/
mkdir -p /home/phil/AppaAppsPhotoApp/java/ 
mkdir -p /home/phil/audioImageCache/ 
mkdir -p /etc/AWSPollyCredentials/ 
mkdir -p /home/phil/AppaAppsPhotoApp/catalog/flags/  
mkdir -p /etc/GitHubCrudPersonalAccessToken/ 
mkdir -p /home/phil/AppaAppsPhotoApp/html/images/  
mkdir -p /home/phil/java/ 
mkdir -p /home/phil/AppaAppsPhotoApp/keys/       
mkdir -p /var/www/html/midi/  
mkdir -p /home/phil/AppaAppsPhotoApp/translations/javaTranslations/  
mkdir -p /home/phil/AppaAppsPhotoApp/zip/
mkdir -p /home/phil/AppaAppsPhotoApp/assets/congratulations/
mkdir -p /home/phil/AppaAppsPhotoApp/assets/prompts/

wget https://github.com/coreliuOrg/photoApp/archive/master.zip
rm        master.zip 
unzip -qo master.zip 
rsync -a photoApp-master/AppaAppsPhotoApp /home/phil/
rsync -a photoApp-master/java        /home/phil/
perl /home/phil/AppaAppsPhotoApp/AppaAppsPhotoApp.pm --install 
ENDCAT
ssh-copy-id root@$1                                                           # Copy identity
rsync -e "ssh -o ForwardX11=no" /tmp/serverSetUpSshd.sh root@$1:serverSetUpSshd.sh                         # Copy server set up file                      
ssh -o ForwardX11=no root@$1 bash serverSetUpSshd.sh                                                 # Bash server set up file  
