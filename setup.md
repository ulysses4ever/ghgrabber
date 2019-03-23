# Setup

This is a quick setup for a droplet on Digital Ocean.

SSH-in as root:

```
apt update && (yes | apt install parallel moreutils gawk)
adduser --gecos '' --disabled-password kondziu
usermod -a -G sudo kondziu
cp -r ~/.ssh /home/kondziu
chown -R kondziu:kondziu /home/kondziu/.ssh/
cd /home/kondziu
runuser -l kondziu -c 'git clone https://github.com/PRL-PRG/ghgrabber.git'
runuser -l kondziu -c 'parallel --citation <<< "echo will cite"'
runuser -l kondziu -c 'screen -S ghgrabber'

```

To run chunk X:

```
CHUNK=
cd /home/kondziu/ghgrabber
./start_chunk.sh $CHUNK
```





