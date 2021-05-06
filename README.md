# covid-vaccine-informer
In the script added in the repo replace 
1) The dictrict id
2) Email on which you want to get the notification 
3) Email from which you want to send info Better create a new one for this in gmail


##Dependencies
1) sudo apt-get install ssmtp
2) sudo apt-get install jq

#Email configuration for gmail
Add following conf to this path /etc/ssmtp/ssmtp.conf

```
root=<new-mail-from-which-mail-to-be-send>
mailhub=smtp.gmail.com:465
rewriteDomain=gmail.com
AuthUser=<new-mail-from-which-mail-to-be-send>
AuthPass=<new-mail-password-from-which-mail-to-be-send>
FromLineOverride=YES
UseTLS=YES
```
