# **NMQR** - share **N**etwork**M**anager wireless network configuration via **QR** code

Android and iOS phones support adding wireless network configuration by QR code... this is a little program that just about manages to do that without combusting.

Requirements:
- a system using [NetworkManager](https://networkmanager.dev/) for network configuration
- [qrencode](https://fukuchi.org/works/qrencode/)
- [grep](https://www.gnu.org/software/grep/)
- [awk](https://www.gnu.org/software/gawk/)
- (optional) either [bash](https://www.gnu.org/software/bash/) or [zsh](https://www.zsh.org/) for completions

Reference:
- [URI syntax](https://github.com/zxing/zxing/wiki/Barcode-Contents#wi-fi-network-config-android-ios-11)
