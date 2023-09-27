# LIBRARY

# Create helm package

```
cd sharedlibraries
helm package .
```

# Push package to Artifactory

Use artifactory 'ORA697639' (EQUIPE-PAPFCD) token

```
PACKAGENAME=package\helm-sharedlibraries-1.X.X.tgz
curl --cacert ~/certificat/Orange_Internal/Orange_Internal_G2_Server_CA_chain.pem -uORA697639:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -T ${PACKAGENAME} "https://multirepo-oab.si.fr.intraorange/artifactory/helm-EQUIPE_PAPF/helm-openshift-config-sharedlibraries/${PACKAGENAME}
```
