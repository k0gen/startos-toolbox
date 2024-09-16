# 🏛️ startos-toolbox

Some simple but useful tools for everyday use.

Download them locally and run or execute them straight from this repository.

## 🚄 speed-test.sh
Will speed test your server's drive

To Run Paste that in a macOS Terminal or Linux shell prompt. 
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/k0gen/startos-toolbox/main/speed-test.sh)"
```
or download and run locally
```
curl -o speed-test.sh https://raw.githubusercontent.com/k0gen/startos-toolbox/main/speed-test.sh
sh speed-test.sh
```
## 🧅 tor-check.sh
Will check your Tor conectivity (if you can actually connect to some .onion services).

To Run Paste that in a macOS Terminal or Linux shell prompt. 
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/k0gen/startos-toolbox/main/tor-check.sh)"
```
or download and run locally
```
curl -o tor-check.sh https://raw.githubusercontent.com/k0gen/startos-toolbox/main/tor-check.sh
sh tor-check.sh
```
> 💡You are advised to download it and add your server's services .onion adresses.

## 🩹 tor-fix.sh
Will delete all Tor state files and restart the daemon showing tor conectivity status.

To Run Paste that in a macOS Terminal or Linux shell prompt. 
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/k0gen/startos-toolbox/main/tor-fix.sh)"
```
or download and run locally
```
curl -o tor-check.sh https://raw.githubusercontent.com/k0gen/startos-toolbox/main/tor-fix.sh
sh tor-fix.sh
```

## 🔍 gather_debug_info.sh
Collects comprehensive system debug information for StartOS.

To run, ssh in to StartOS and paste this to shell prompt:
```
curl -sSL https://raw.githubusercontent.com/k0gen/startos-toolbox/main/gather_debug_info.sh -o gather_debug_info.sh && chmod +x gather_debug_info.sh && sudo ./gather_debug_info.sh
```
or manually download, examine and run locally
```
curl -o gather_debug_info.sh https://raw.githubusercontent.com/k0gen/startos-toolbox/main/gather_debug_info.sh sudo sh gather_debug_info.sh
```
This script collects detailed system information including StartOS version, CPU, memory, storage, network, and more. It saves the information to a file and offers to send it to Start9 support using the `wormhole` command.
