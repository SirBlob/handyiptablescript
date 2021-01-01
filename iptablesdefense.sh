#!/bin/bash
#Note these rules are only for ipv4 and in the future add ipv6 if needed

dash() {
	printf -- '-%.0s' {1..100}; echo ""
}

backuptable() {
	dash
	echo "Enter backup file name."
	read -p "Backup iptable name: " backupname
	iptables-save > $backupname.txt
	dash
	echo "Saved in: $(pwd) with filename $backupname.txt"
	dash
}

invalidchoice() {
	dash
	echo "Invalid Choice"
	dash
}

echo "Welcome to some common firewall attacks and how to prevent them."
PS3="Please enter your choice: "

option=("Policies" "Specific Attack Prevention" "Worst Case Options" "Backup / Restore")

poly=("Deny by Default" "Accept by Default")
attk=("Ping Flood" "TCP SYN Flood" "Malformed Packets" "Smurf Attack")
worst=("Block All Incoming Traffic" "Flush All Rules")
back=("Backup Current" "Restore from backup")

select x in "${option[@]}"
do
	case $x in 
		"Policies")
			select pol in "${poly[@]}"
			do
				case $pol in
					"Deny by Default")
						dash
						echo "Changing Default to DROP"
						iptables -P INPUT DROP
						iptables -P FORWARD DROP
						iptables -P OUTPUT ACCEPT
						;;
					"Accept by Default")
						dash
						echo "Changing Default to ACCEPT"
						iptables -P INPUT ACCEPT
						iptables -P FORWARD ACCEPT
						iptables -P OUTPUT ACCEPT
						;;
					*)
						invalidchoice
						;;						
				esac
			done
			;;
		"Specific Attack Prevention")
			select ap in "${attk[@]}"
			do
				case $ap in
					"Ping Flood")
						dash
						echo "Blocking incoming ICMP Echo Requests"
						#DROP icmp echo request type 8
						iptables -A INPUT -j DROP -p icmp --icmp-type echo-request
						dash				
						;;
					"TCP SYN Flood")
						dash
						echo "Blocking TCP SYN Flood"
						#Limit the amount of new connection
						#Drop all other packets that don't match the limit rule otherwise will be accepted
						iptables -A INPUT -p tcp -m state --state NEW -m limit --limit 2/second --limit-burst 2 -j ACCEPT
						iptables -A INPUT –p tcp –m state --state NEW -j DROP
						dash
						;;
					"Malformed Packets")
						dash
						echo "Blocking Malformed XMAS Packets"
						#Drop packets with the flags that looks like xmas tree
						iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
						
						dash
						echo "Blocking Fragmented Packets"
						#Drop packets that are fragemented
						iptables -A INPUT -f -j DROP

						dash
						echo "Blocking NULL packets"
						#Drop packets that are NULL
						iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
						dash
						;;
					"Smurf Attack")
						dash
						echo "Blocking Smurf Attack"
						#limits icmp packets and drops the other
						iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j ACCEPT
						iptables -A INPUT -p icmp -j DROP
						dash
						;;
					*)
						invalidchoice
						;;
				esac
			done
			;;
		"Worst Case Options")
			echo "Be absolutely sure before running these commands."
			select w in "${worst[@]}"
			do
				case $w in
					"Block All Incoming Traffic")
						#ask them if they want to back up #maybe move backup to a function
						echo "NOTE: This will also block SSH access!!"
						read -p "Are you sure? [Y/N]: " runconfirm
						if [[ "$runconfirm" =~ ^(yes|y|Y|YES)$ ]]
						then
							dash
							echo "Blocking all internal and external traffic"

							#Default chain policies
							iptables -P INPUT DROP #drop all incoming
							iptables -P FORWARD DROP #drop all forwarded
							iptables -P OUTPUT ACCEPT #accept outgoing

							#Accept Localhost
							iptables -A INPUT -i lo -j ACCEPT #loopback input
							iptables -A OUTPUT -o lo -j ACCEPT #loopback output

							#Established Sessions continue to receive traffic
							iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
							dash
						else
							dash
							echo "Exiting"
							dash
							break
						fi
						;;
					"Flush All Rules")
						read -p "Would you like to back up the current rules before proceeding? [Y/N]: " confirmremove
						if [[ "$confirmremove" =~ ^(yes|y|Y|Yes)$ ]]
						then
							if backuptable
							then
								dash
								echo "FLushing Rules"
								dash
								iptables --flush
								dash
								echo "See current iptable"
								dash
								iptables -L --line-numbers
							else
								dash
								echo "Backup failed"
								echo "Exiting Script"
								dash
								break
							fi
						elif [[ "$confirmremove" =~ ^(no|n|N|NO|No) ]]
						then
							dash
							echo "Flushing all rules"
							dash
							iptables --flush
							dash
							echo "See current iptable"
							dash
							iptables -L --line-numbers
						else
							invalidchoice
						fi
						;;
					*)
						invalidchoice
						;;
				esac
			done
			;;
		"Backup / Restore")
			select b in "${back[@]}"
			do
				case $b in 
					"Backup Current")
						backuptable
						;;
					"Restore from backup")
						dash
						echo "Enter backup file name"
						read -p "Restore from file: " restorename
						iptables-restore < $restorename.txt
						dash
						echo "Restored from file: $restorename.txt"
						dash
						;;
					*)
						invalidchoice
						;;
				esac
			done
			;;
		*)
			invalidchoice
			;;
	esac
done




