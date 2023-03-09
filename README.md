# kali-bridge
Highly inspired by [readloud/kali-router](https://github.com/readloud/kali-router) but without wifi ap and improved for own kali setup.

## Setup
Just set the interface that should be connected to your client (e.g. a RaspberryPI) to unmanaged (see the first section [here](https://github.com/readloud/kali-router#configuring-kali-linux-as-a-router)). Then review the configuration in `conf/dnsmasq.conf` and the top variables inside `monitor-bridge.sh`.

## Usage
To start the bridge with monitoring, just run:
```bash
./monitor-bridge.sh
```
When done, hit CTRL+C and everything should shut down gracefully.

If you need to forcefully reverse the changes made, you can run:
```bash
./monitor-bridge.sh --down
```
After that, everything should be back to normal.

## Logs/Output
dnsmasq: `/tmp/dnsmasq.log`
wireshark: `dumps/output.pcap`
