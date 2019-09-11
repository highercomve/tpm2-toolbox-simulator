Docker container with TPM 2.0 toolbox running over TPM SIMULATOR
================================================================

This container includes:

- tpm2-tss
- tpm2-abrmd
- tpm2-tools
- tpm_server (2.0 version)

## How to run the container

```bash
docker run --rm -it -v /FOLDER_TO_SAVE_THE_SIMULATOR_NVFILE:/tpm2 highercomve/tpm2_toolbox bash
```

### Enrolling your first certs

```bash
tpm2_createek -c ek.handle -G rsa -f pem -u ek.pub.pem
pki --gen --type ecdsa --size 256 --outform pem > demoCaKey.pem
pki --self --ca --type ecdsa --in demoCaKey.pem --dn="C=US, O=Demo, CN=Demo ACA" --lifetime 3652 --outform pem > demoCaCert.pem
openssl x509 -in demoCaCert.pem -inform pem -outform der -out demoCaCert.der
tpm2_nvdefine -Q 2 -C p -a "ownerread|policywrite|ownerwrite|platformcreate|no_da"
tpm2_nvwrite -Q 2 -C o -i demoCaCert.der
```

You could use the EK cert to issue other certs

```
pki --issue --cacert demoCaCert.pem --cakey demoCaKey.pem --type pub --in ek.pub.pem --dn "C=UK, O=Demo, OU=EK RSA, CN=${deviceid}.devicecerts.aca.demo.com" --lifetime 3651 > device.pem
```

For more documentation on TPM2

[https://github.com/tpm2-software/tpm2-tools](https://github.com/tpm2-software/tpm2-tools)

The tpm2-tools wiki: [https://github.com/tpm2-software/tpm2-tools/wiki](https://github.com/tpm2-software/tpm2-tools/wiki)

TPM 2.0 specifications can be found at [Trusted Computing Group](https://trustedcomputinggroup.org/).
