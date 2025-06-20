#!/usr/bin/env bash

# Temporary internet fix
# IFTW (If fails to work): add `ipv4.ignore-auto-dns yes` in nmcli con mod

nmcli con mod "AntarNet" ipv4.gateway "192.168.1.1" ipv4.address "192.168.1.252" ipv4.dns "127.0.0.1" ipv4.method manual
nmcli con mod "Source Sauce" ipv4.gateway "192.168.31.1" ipv4.address "192.168.31.252" ipv4.dns "127.0.0.1" ipv4.method manual
nmcli con down AntarNet
sudo systemctl restart iwd NetworkManager dnscrypt-proxy
nmcli con up  AntarNet
ping -c 3 1.1.1.1
ping -c 3 archlinux.org
