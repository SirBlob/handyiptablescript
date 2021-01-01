# Bash Script for some handy iptable commands

## Main Categories
1. Policies
```
  a. Deny by Default
  b. Accept by Default
  ```
2. Specific Attacks Prevention
```
  a. Ping Flood  
  b. TCP SYN Flood  
  c. Malformed Packets  
  d. Smurf Attacks
  ```
3. Worst Case Options
```
  a. Block all incoming traffic  
  b. Flush all rules
  ```
4. Backup / Restore
```
  a. Backup current rules
  b. Restore from backup
```
### Introduction
I wanted to create a script to help enhance my understanding of cyber security concepts and to learn more about iptables.

#### Improvements To be Made
1. More Specific Attacks
2. Add other handy iptables commands (Initial Setup, etc..)
3. Add IPv6 conversion as currently it is only for IPv4

#### Optimizations to keep in mind
1. Place loopback / forwarding rules as early as possible
2. Use state / connection tracking modules to bypass fire wall for established connections
3. Combine rules to standard TCP clientserver connections to single rule w/ port list heavy traffic servers rules as early as possible

#### Sources
1. https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands
2. https://www.crybit.com/how-to-save-current-iptables-rules/
3. https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules#:~:text=To%20flush%20a%20specific%20chain,sudo%20iptables%20%2DF%20INPUT
4. https://linuxhint.com/how_to_use_ip_tables_to_block_icmp/
