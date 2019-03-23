# Setup

This is a quick setup for a droplet on Digital Ocean.

SSH-in as root:

```
apt update && (yes | apt install parallel moreutils gawk)
adduser --gecos '' --disable-password kondziu
usermod -a -G sudo kondziu
cp -r ~/.ssh /home/kondziu
chown -R kondziu:kondziu /home/kondziu/.ssh/

#su kondziu
cd /home/kondziu
runuser -l kondziu -c 'git clone https://github.com/PRL-PRG/ghgrabber.git'
runuser -l kondziu -c 'yes 'will cite' | parallel --citation'
```

To run chunk X:

```
cd /home/kondziu/ghgrabber
screen -dm './start_chunk.sh X` -S ghgrabber'
```





