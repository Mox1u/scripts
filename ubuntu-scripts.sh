#!/usr/bin/env bash
#
# Script to set up an Ubuntu 22.04+ server
# (with minimum 16GB RAM, 6-8 threads CPU) for Android ROM compiling
#
# Sudo access is mandatory to run this script
#
# IMPORTANT NOTICE: Update your personal git config before running this script!
#
# Usage:
#   ./ubuntu-setup.sh
#

echo -e "Updating and installing APT packages...\n"
sudo apt update -qq
sudo apt install -y -qq git-core gnupg flex bc bison build-essential zip curl zlib1g-dev gcc-multilib \
                        g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev jq \
                        lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python3 python3-pip \
                        python3-dev python-is-python3 ccache default-jdk libxml-simple-perl rsync nano
sudo apt autoremove -y -qq
sudo apt purge snapd -y -qq
echo -e "\nDone."

echo -e "\nInstalling git-repo..."
wget -q https://storage.googleapis.com/git-repo-downloads/repo
chmod a+x repo
sudo install repo /usr/local/bin/repo
rm repo
echo -e "Done."

echo -e "\nInstalling GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
echo -e "Done."

echo -e "\nInstalling APKTool and JADX..."
mkdir -p bin
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.0.jar -O bin/apktool.jar
echo 'alias apktool="java -jar $HOME/bin/apktool.jar"' >> ~/.bashrc

wget -q https://github.com/skylot/jadx/releases/download/v1.4.7/jadx-1.4.7.zip -O jadx.zip
unzip -qq jadx.zip -d jadx
rm jadx.zip
echo 'export PATH="$HOME/jadx/bin:$PATH"' >> ~/.bashrc
echo -e "Done."

# Add fast repo sync to .bashrc
cat <<'EOF' >> ~/.bashrc
# Super-fast repo sync
repofastsync() { time schedtool -B -e ionice -n 0 `which repo` sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --retry-fetches=5 -j$(nproc --all) "$@"; }
EOF

# Unlimited history file
sed -i 's/HISTSIZE=.*/HISTSIZE=-1/g' ~/.bashrc
sed -i 's/HISTFILESIZE=.*/HISTFILESIZE=-1/g' ~/.bashrc

echo -e "Done."

# Configure Git
echo -e "\nSetting up Git..."
git config --global user.email "186339690+Mox1u@users.noreply.github.com"
git config --global user.name "Nathan"
git config --global alias.cp 'cherry-pick'
git config --global alias.c 'commit'
git config --global alias.f 'fetch'
git config --global alias.m 'merge'
git config --global alias.rb 'rebase'
git config --global alias.rs 'reset'
git config --global alias.ck 'checkout'
git config --global credential.helper 'cache --timeout=99999999'
git config --global core.editor "nano"
echo "Done."

# Done!
echo -e "\nALL DONE. Now sync sources & start baking!"
echo -e "Please relogin or run \`source ~/.bashrc && source ~/.profile\` for environment changes to take effect.
