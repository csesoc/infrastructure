# CSESoc Infra SSL

Hello reader! It's probably that time of year again where it's time to renew SSL certificates. No need to fear the unknown! It's all documented here! 😁

UNSW IT will issue certificates for free. There is no need to pay a third party for certificates. 

## Requesting a certificate
To request a new certificate from UNSW IT you must generate a private key & CSR. If you are simply renewing a certificate, you can probably skip onto the [CSR generation step](#generate-the-csr) (unless you have suspicion the private key has been compromised)

```bash
export DOMAIN=foo.cse.unsw.edu.au
mkdir "${DOMAIN}"
cp openssl.example.cnf "${DOMAIN}/openssl.cnf"
```

Once copied, open `openssl.cnf` in your favourite editor, and find the `alt_names` section. Modify the entries for `DNS.x` accordingly:

```
[alt_names]
DNS.1 = foo.cse.unsw.edu.au
DNS.2 = *.foo.cse.unsw.edu.au
```

### Generate the CSR

Once you're happy with that, it's time to generate the key and CSR.

```bash
export DOMAIN=foo.cse.unsw.edu.au
openssl req -new -newkey rsa:4096 -nodes \
  -keyout "${DOMAIN}/${DOMAIN}.key" \
  -out "${DOMAIN}/${DOMAIN}".csr \
  -subj "/CN=${DOMAIN}/emailAddress=projects@csesoc.org.au/C=AU/ST=New South Wales/L=Kensington/O=UNSW Computer Science Society" \
  -config "${DOMAIN}/openssl.cnf"
```

You can inspect the CSR to make sure everything looks OK:

```bash
openssl req -in "${DOMAIN}/${DOMAIN}.csr" -noout -text
```

UNSW IT will return signed certificate. Place it in the directory with the name `${DOMAIN}.crt`.

Easy Peasy! Make sure you inspect the certificate and find out it's expiry date, set a reminder for 3 months before that to renew it again to make sure you don't experience any downtime 😁

## Create Certificate Chain
You may need to create the certificate bundle/chain that can be used by `nginx`. This can be done by simply appending the CA chain to the bottom of the file. i.e:

- Your cert
- CA intermediate cert
- CA cert  

You should be able to obtain the CA cert and intermediate certificates from the certificate authority that signed the certificate. At the time of writing, UNSW IT provided a link to these at the bottom of their reply email.
  
```bash
cat "${DOMAIN}.crt" ca-intermediate.crt ca.crt > "${DOMAIN}.bundle.crt"
``` 

## Re-deploy updated certificates

Once the renewed certificates are in the correct place in this repo, you will need to re-deploy them to the production environment by running the apropriate playbook. See [Using Ansible](../README.md#using-ansible--running-playbooks).

```bash
ansible-playbook  -l wheatley playbooks/wheatley-apps.playbook.yml
```

Additionally, you will need to provide the updated certificate and private key to [Rancher's SSL termination](https://wheatley.cse.unsw.edu.au:7654/env/1a5/infra/certificates). 

# FAQ

## Why not use letsencrypt
At the time of writing it is impossible to obtain 
certificates via a third party due to the CAA configuation on the 
csesoc.unsw.edu.au domain anyway:


```
dig CAA unsw.edu.au

; <<>> DiG 9.9.7-P3 <<>> CAA unsw.edu.au
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 23683
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;unsw.edu.au.			IN	CAA

;; ANSWER SECTION:
unsw.edu.au.		3589	IN	CAA	0 issue "quovadisglobal.com"

;; Query time: 99 msec
;; SERVER: 192.168.8.1#53(192.168.8.1)
;; WHEN: Thu Apr 12 20:13:43 AEST 2018
;; MSG SIZE  rcvd: 77
``` 

This means that letsencrypt cannot be used for automatic certificate renewal. This may 
change in the future, so keep your eyes out!
