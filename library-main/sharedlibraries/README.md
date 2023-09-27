
[[_TOC_]]

# Charger la libraries dans votre projet :

dans votre 'Charts.yaml' principal , vous devez utilisé la libraries :

```yml
dependencies:
- name: helm-sharedlibraries
  version: 1.0.0
  repository: https://multirepo-oab.si.fr.intraorange/artifactory/helm-EQUIPE_PAPF

```
# Utiliser un template

Pour utiliser un template particulier, vous devrez dans un premier temps chargé celui-ci :

Par exemple :
Dans un fichier `templates/role.yaml`

```yml
{{/* load shared libraby for role creation */}}
{{ include "sharedlibraries.rbac_role" . }}

```

Puis dans vos Values , vous devrez utilisé les valeur attendues par ce templates

Exemple:
```yml
rbac:
  r:
    # Role for creation and use of ressource used for ingress
    - name: &roleelnaingress r-xxxxx-ingress
      namespace: xxxxxx
      # OPT
      additionalLabel:
        firstAdditionalLabel: "label name"
      # OPT
      additionalAnnotations:
        firstAdditionalAnnotation: "annotation name"
      syncWave: -3
      rules:
        - apiGroups:
            - ""
          resources:
            - services
            - secrets
            - deployments
          verbs: ["*"]

```

Pour la liste , voir ci-dessous


# Liste des template disponible
## [Default](#parametre-default)
## [EgressIP](#parametre-egressip)

## RBAC
### [RBAC role](#parametre-rbac-role)
### [RBAC binding](#parametre-rbac-binding)
### [RBAC serviceaccount](#parametre-rbac-serviceaccount)

## OPERATOR
### [OPERATOR group](#parametre-operator-group)
### [OPERATOR subscription](#parametre-operator-subscription)
### [OPERATOR job installplan](#parametre-operator-job-installplan)

## METALLB
### [METALLB controller](#parametre-metallb-controller)
### [METALLB ip-pool](#parametre-metallb-ip-pool)
### [METALLB l2advertisements](#parametre-metallb-l2advertisements)

## Ingress
### NGINX
#### [NGINX ingress-controller](#parametre-nginx-ingress-controller)
#### [NGINX transport-server](#parametre-nginx-transport-server)
#### [NGINX virtual-server](#parametre-nginx-virtual-server)
### Traefik
#### [Traefik ingressroute](#parametre-traefik-ingressroute)
#### [Traefik ingressroutetcp](#parametre-traefik-ingressroutetcp)
#### [Traefik ingressrouteudp](#parametre-traefik-ingressrouteudp)
#### [Traefik middleware](#parametre-traefik-middleware)
#### [Traefik middlewaretcp](#parametre-traefik-middlewaretcp)
#### [Traefik tlsoption](#parametre-traefik-tlsoption)

## Certificate
### CertManager
#### [CertManager certificate](#parametre-certmanager-certificate)
#### [CertManager clusterissuer](#parametre-certmanager-clusterissuer)
#### [CertManager clusterissuer](#parametre-certmanager-clusterissuer)
### StepIssuer
#### [StepIssuer stepclusterissuer](#parametre-stepissuer-stepclusterissuer)
#### [StepIssuer stepissuer](#parametre-stepissuer-stepissuer)

## ESO (External Secret Operator)
### [ESO SecretStore](#parametre-eso-secretstore)
### [ESO externalsecret](#parametre-eso-externalsecret)

## Minio
### [Minio tenant](#parametre-minio-tenant)

## Reloader
### [Reloader](#parametre-reloader)

## Workload
### [Deployements](#parametre-workload-deployements)
### [StatefulSets](#parametre-workload-statefulsets)

## Secret / ConfigMap
### [Secret](#parametre-secret)
### [ConfigMap](#parametre-configmap)

## Network
### [Services](#parametre-network-services)
### [NetworkPolicy](#parametre-network-networkpolicy)





# Liste des fonction / helper des templates HELM
## [checkVariableDict](#parametre-template-checkvariabledict)
## [checkVariableList](#parametre-template-checkvariablelist)
## [checkVariableList](#parametre-template-checkvariablelist)
## [dump](#parametre-template-dump)
## [AdditionnalInfos](#parametre-template-AdditionnalInfos)


Les template commence toujours par '_'

# Parametre des templates:
## Parametre Default:

Les templates possède une function pour afficher  :
 - additionalAnnotations
 - additionalLabels
 - syncWave

Les templates ajoute les labels et annotations suivantes :

 - label release : helm chart release name
 - label heritage : helm chart release name
 - annotation managed : argocd.argoproj.io/managed: "true"
 - annotation application-name : argocd.argoproj.io/application-name: {{ $.Release.Name }}



```yml
  # annotation definie dans les templates :
  argocd.argoproj.io/managed: "true"
  argocd.argoproj.io/application-name: {{ $.Release.Name }}

  # additionalAnnotations
  # format : map / dict
  # [OPT]
  additionalAnnotations:
    620nm.net\another-annotation: values

  # Labels definie dans les templates :
  release: {{ $.Release.Name }}
  heritage: {{ $.Release.Service }}

  # additionalLabels
  # format : map / dict
  # [OPT]
  additionalLabels:
    620nm.net\another-label: values

  # Etape ArgoCD
  # DEF : xx
  # [OPT]
  syncWave: 01
  # -> argocd.argoproj.io/sync-wave: {{ default "00" $xxxxxxxxx.syncWave | squote }}

```

## Parametre EgressIP

```yml
{{ include "sharedlibraries.egressip" . }}
```


```yml
egressIp:
    # egressIp name
    # [REQ]
  - name: egress1
    # Etape ArgoCD
    # DEF : 02
    # [OPT]
    syncWave: 02

    # Ensemble des IPs disponible pour l'egress
    # [REQ]
    egressIPs:
    - 192.168.5.5
    - 192.168.6.6

    # Selection du namespace
    # All of the requirements, from both matchLabels and matchExpressions are ANDed together
    # -- they must all be satisfied in order to match.
    # [REQ]
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: outils
      matchExpressions:

    # Selection du pod
    # [OPT]
    podSelector:
      620nm.net/egressip: test

```

## RBAC
### Parametre RBAC role

```yml
{{ include "sharedlibraries.rbac_role" . }}
```


```yml
rbac:
  # [REQ] one of  ClusterRole(cr) or Role(r)

  # -- Create RBAC ClusterRole(cr)
  cr:
      # ClusterRole name
      # [REQ]
    - name: "cr-machintruc"
      # Etape ArgoCD
      # DEF : -1
      # [OPT]
      syncWave: "-1"

      # Rules
      # write as YAML (with validation)
      # [REQ]
      rules:
        - apiGroups:
            - k8s.ovn.org
          resources:
            - egressips
          verbs: ["*"]

  # -- Create RBAC Role (r)
  r:
      # Role name
      # [REQ]
    - name: "r-machintruc"
      # Role namespace
      # [REQ]
      namespace: thisnamespace
      # Etape ArgoCD
      # DEF : -1
      # [OPT]
      syncWave: "-1"

      # Rules
      # write as YAML (with validation)
      # [REQ]
      rules:
          # apiGroups
          # [REQ]
        - apiGroups:
            - k8s.ovn.org
          # resources
          # [REQ]
          resources:
            - egressips
          # verbs
          # [REQ]
          verbs: ["*"]
```

### Parametre RBAC binding

```yml
{{ include "sharedlibraries.rbac_binding" . }}
```


```yml
rbac:
  # [REQ] one of  ClusterRoleBinding(crb) or RoleBinding(rb)

  # -- Create RBAC ClusterRoleBinding(crb)
  crb:
      # ClusterRoleBinding name
      # [REQ]
    - name: "crb-machintruc"
      # Etape ArgoCD
      # DEF : 00
      # [OPT]
      syncWave: "00"

      # subjects
      # write as YAML (with validation)
      # [REQ]
      subjects:
          # kind
          # [REQ]
        - kind: Group
          # name
          # [REQ]
          name: 'system:serviceaccounts:itgelna'
          # apiGroup
          # [REQ]
          apiGroup: rbac.authorization.k8s.io

      # roleRef
      # write as YAML (with validation)
      # [REQ]
      roleRef:
        # kind
        # [REQ]
        kind: Role
        # name
        # [REQ]
        name: workspace
        # apiGroup
        # [REQ]
        apiGroup: rbac.authorization.k8s.io

  # -- Create RBAC RoleBinding
  rb:
      # RoleBinding name
      # [REQ]
    - name: "rb-machintruc"
      # RoleBinding namespace
      # [REQ]
      namespace: thisnamespace
      # Etape ArgoCD
      # DEF : 00
      # [OPT]
      syncWave: "00"

      # subjects
      # write as YAML (with validation)
      # [REQ]
      subjects:
          # kind
          # [REQ]
        - kind: Group
          # name
          # [REQ]
          name: 'system:serviceaccounts:itgelna'
          # apiGroup
          # [REQ]
          apiGroup: rbac.authorization.k8s.io

      # roleRef
      # write as YAML (with validation)
      # [REQ]
      roleRef:
        # kind
        # [REQ]
        kind: Role
        # name
        # [REQ]
        name: workspace
        # apiGroup
        # [REQ]
        apiGroup: rbac.authorization.k8s.io

```

### Parametre RBAC serviceaccount

```yml
{{ include "sharedlibraries.rbac_serviceaccount" . }}
```


```yml
rbac:
  # -- Create RBAC ServiceAccount (sa)
  # [REQ]
  sa:
      # ServiceAccount name
      # [REQ]
    - name: sa-machintruc

      # ServiceAccount namespace
      # [REQ]
      namespace: thisnamespace

      # Etape ArgoCD
      # DEF : -1
      # [OPT]
      syncWave: "-1"

      # HELPER ServiceAccount AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # additionalLabel
      # additionalAnnotations
      # syncWave

```
## OPERATOR
### Parametre OPERATOR group

```yml
{{ include "sharedlibraries.operator_group" . }}
```


```yml
operator:
  # -- Create OPERATOR group
  # [REQ]
  group:
      # OPERATOR group name
      # [REQ]
    - name: metallb
      # OPERATOR group namespace
      # [REQ]
      namespace: *namespace
      # Etape ArgoCD
      # DEF : 01
      # [OPT]
      syncWave: 00

      # HELPER group AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # syncWave

      # Example valid config:
      targetNamespaces: []
      selector:
      serviceAccountName:

```

### Parametre OPERATOR subscription

```yml
{{ include "sharedlibraries.operator_subscription" . }}
```


```yml
operator:
  # -- Create OPERATOR subscription
  # [REQ]
  subscription:
      # OPERATOR subscription name
      # [REQ]
    - name: metallb
      # OPERATOR subscription namespace
      # [REQ]
      namespace: *namespace
      # Etape ArgoCD
      # DEF : 01
      # [OPT]
      syncWave: 01

      # OPERATOR subscription channel
      # [REQ]
      channel: "stable"

      # OPERATOR subscription installPlanApproval
      # Manual with another template (job installplan)
      # [REQ]
      installPlanApproval: Manual

      # OPERATOR subscription operatorName
      # [REQ]
      operatorName: metallb-operator

      # OPERATOR subscription source
      # [REQ]
      source: redhat-operators

      # OPERATOR subscription sourceNamespace
      # [REQ]
      sourceNamespace: openshift-marketplace


      # HELPER subscription AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # syncWave
      # channel
      # installPlanApproval
      # operatorName
      # source
      # sourceNamespace

```


### Parametre OPERATOR job installplan

```yml
{{ include "sharedlibraries.job_installplan" . }}
```


```yml
job:
  # -- Create OPERATOR job installplan
  # [REQ]
  installplan:
      # OPERATOR subscription name
      # [REQ]
    - name: metallb
      # OPERATOR subscription namespace
      # [REQ]
      namespace: *namespace
      # Etape ArgoCD
      # DEF : 01
      # [OPT]
      syncWave: 01

      # HELPER installplan AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # syncWave
      # template

      template:
        spec:
          # HELPER template.spec AdditionnalInfos
          # write as YAML (without formating or validation) everything
          # Example valid config:
          dnsPolicy: ClusterFirst
          restartPolicy: OnFailure
          terminationGracePeriodSeconds: 30
          serviceAccount: sa-installplan-approver
          serviceAccountName: sa-installplan-approver


```


## METALLB
### Parametre METALLB controller

```yml
{{ include "sharedlibraries.metallb_controller" . }}
```


```yml
metalLB:
  # -- Create METALLB controller
  # [REQ]
  controller:
      # METALLB controller name
      # MUST BE metallb
      # [REQ]
    - name: metallb
      # METALLB controller namespace
      # [REQ]
      namespace: metallb-system
      # Etape ArgoCD
      # DEF : 03
      # [OPT]
      syncWave: 03

      # HELPER controller AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # syncWave

```

### Parametre METALLB ipPool

```yml
{{ include "sharedlibraries.metallb_ippool" . }}
```


```yml
metalLB:
  # -- Create METALLB ipPool
  # [REQ]
  ipPool:
      # METALLB controller name
      # MUST BE metallb
      # [REQ]
    - name: ippool
      # METALLB controller namespace
      # [REQ]
      namespace: metallb-system
      # Etape ArgoCD
      # DEF : 03
      # [OPT]
      syncWave: 03

      # addresses
      # [REQ]
      addresses:
        - 172.31.164.10-172.31.164.250
        - 172.31.165.10-172.31.165.250

      # autoAssign
      # [OPT]
      autoAssign: false

      # HELPER ipPool AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # syncWave
      # addresses
      # autoAssign

```


### Parametre METALLB l2advertisements

```yml
{{ include "sharedlibraries.metallb_l2advertisements" . }}
```


```yml
metalLB:
  # -- Create METALLB ipPool
  # [REQ]
  l2Adv:
      # METALLB controller name
      # MUST BE metallb
      # [REQ]
    - name: l2adv
      # METALLB controller namespace
      # [REQ]
      namespace: metallb-system
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # ipAddressPools
      # [REQ]
      ipAddressPools:
        - ipPool

      # ipAddressPoolSelectors
      # [OPT]
      ipAddressPoolSelectors:

      # nodeSelectors
      # [OPT]
      nodeSelectors:

      # HELPER l2Adv AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # syncWave
      # ipAddressPools
      # ipAddressPoolSelectors
      # nodeSelectors

```



## Ingress
### NGINX
#### Parametre NGINX ingress-controller (DEPRACATED)

```yml
{{ include "sharedlibraries.nginx_ingress_controller" . }}
```


```yml
nginx:
  # -- Create NGINX controller
  # DOC : https://github.com/nginxinc/nginx-ingress-helm-operator/blob/v1.3.0/docs/nginx-ingress-controller.md
  # HELPER :
  #if you set service.customPorts , globalConfiguration.spec.listener will be created from service info
  # [REQ]
  controller:
      # NGINX controller name
      # [REQ]
    - name: nginx-ingress
      # NGINX controller namespace
      # [REQ]
      namespace: nginxingress
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # pod
      # [OPT]
      pod:
        # annotation definie dans le template :
        annotations:
          argocd.argoproj.io/managed: "true"
          argocd.argoproj.io/application-name: {{ $.Release.Name }}

        # HELPER pod AdditionnalInfos
        # write as YAML (without formating or validation)

      # service
      # [OPT]
      service:
        # annotation definie dans le template :
        annotations:
          argocd.argoproj.io/managed: "true"
          argocd.argoproj.io/application-name: {{ $.Release.Name }}

        # create
        # DEF : true
        # [OPT]
        create: true

        # customPorts
        # [OPT]
        customPorts:

            # customPorts name
            # [OPT]
          - name: portx
            port: 3000

            # HELPER customPorts AdditionnalInfos
            # write as YAML (without formating or validation) everything except:
            # name

          # HELPER service AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # name

      # globalConfiguration
      # [OPT]
      globalConfiguration:

        # create
        # DEF : true
        # [OPT]
        create: true

        spec:
          # listeners
          # [OPT]
          listeners:

        # HELPER globalConfiguration AdditionnalInfos
        # write as YAML (without formating or validation) everything except:
        # listeners

      # HELPER controller AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # globalConfiguration
      # service
      # pod

      # Example valid config:
      ingressClass: testingressclass
      enableCertManager: false
      healthStatus: true
      kind: deployment
      nginxStatus:
        allowCidrs: 127.0.0.1
        enable: true
        port: 8080
      enableCustomResources: true

```


#### Parametre NGINX transport-server (DEPRACATED)

```yml
{{ include "sharedlibraries.nginx_transport_server" . }}
```


```yml
nginx:
  # -- Create NGINX transport-server
  # DOC : https://docs.nginx.com/nginx-ingress-controller/configuration/transportserver-resource/
  # [REQ]
  transport-server:
      # NGINX transport-server name
      # [REQ]
    - name: ts-nginxingress
      # NGINX transport-server namespace
      # [REQ]
      namespace: nginxingress
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # ingressClassName
      # [REQ]
      ingressClassName:

      # listener
      # format : map / dict
      # [REQ]
      listener:
        # listener name
        # [REQ]
        name: ltn-test
        # listener protocol
        # [REQ]
        protocol: TCP

      # upstreams
      # format : list
      # [REQ]
      upstreams:
          # upstreams name
          # [REQ]
        - name: upstream-test
          # upstreams port
          # [REQ]
          port: 3000
          # upstreams service
          # [REQ]
          service: svc-test

          # HELPER upstreams AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # name
          # port
          # service

      # action
      # format : map / dict
      # [REQ]
      action:
        # action name
        # [REQ]
        pass: upstream-test


      # HELPER transport-server AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # ingressClassName
      # listener
      # upstreams
      # action

```

#### Parametre NGINX virtual-server (DEPRACATED)

```yml
{{ include "sharedlibraries.nginx_virtual_server" . }}
```


```yml
nginx:
  # -- Create NGINX virtual-server
  # DOC : https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/
  # [REQ]
  virtual-server:
      # NGINX virtual-server name
      # [REQ]
    - name: vs-nginxingress
      # NGINX virtual-server namespace
      # [REQ]
      namespace: nginxingress
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # host
      # [REQ]
      host:

      # ingressClassName
      # [REQ]
      ingressClassName:

      # routes
      # format : list
      # [REQ]
      routes:
          # routes path
          # [REQ]
        - path: /test

          # routes action
          # [REQ]
          action:
            pass: upstream-test

            # HELPER routes action AdditionnalInfos
            # write as YAML (without formating or validation) everything except:
            # pass

          # HELPER routes AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # path
          # action
          # service

      # upstreams
      # format : list
      # [REQ]
      upstreams:
          # upstreams name
          # [REQ]
        - name: upstream-test
          # upstreams port
          # [REQ]
          port: 3000
          # upstreams service
          # [REQ]
          service: svc-test

          # HELPER upstreams AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # name
          # port
          # service

      # HELPER virtual-server AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # host
      # ingressClassName
      # routes
      # upstreams

```

### TRAEFIK
#### Parametre TRAEFIK ingressroute

```yml
{{ include "sharedlibraries.traefik_ingressroute" . }}
```


```yml
traefik:
  # -- Create TRAEFIK ingressRoute
  # DOC : https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/
  # [REQ]
  ingressRoute:
    - name: traefik-ingressroute
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # entryPoints
      # DEF : all
      # format : list
      # [OPT]
      entryPoints:
        - web
        - websecure

      # routes
      # format : list
      # [REQ]
      routes:
          # kind
          # DEF : rule
          # [REQ]
        - kind: rule

          # match
          # format : string
          # [OPT]
          match: HostSNI(`*`)

          # services
          # DEF : list
          # [REQ]
          # DOC : https://doc.traefik.io/traefik/routing/services/#configuring-http-services
          services:
            - kind: Service
              name: foo
              namespace: default

              # HELPER routes.services AdditionnalInfos
              # write as YAML (without formating or validation) everything except :
              # kind
              # name
              # namespace
              # Example valid config:

              passHostHeader: true
              port: 80                      # [9]
              responseForwarding:
                flushInterval: 1ms
              scheme: https
              serversTransport: transport   # [10]
              sticky:
                cookie:
                  httpOnly: true
                  name: cookie
                  secure: true
                  sameSite: none
              strategy: RoundRobin
              weight: 10

          # HELPER routes AdditionnalInfos
          # write as YAML (without formating or validation) everything except :
          # kind
          # match
          # services
          # Example valid config:

          # middlewares
          # DEF : list
          # [OPT]
          middlewares:
            - name: middleware1
              namespace: default

          # priority
          # format : integer
          # DEF : 0  (disable)
          # [OPT]
          priority: 0

      # HELPER ingressroute AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # routes
      # entryPoints

      # tls
      # DEF : all
      # [OPT]
      tls:

        # format : string
        # NOT RECOMMANDED
        # [OPT]
        certResolver: oabresolver

        # domains
        # format : dict
        # [OPT]
        domains:

          # main
          # format : string
          # [OPT]
          main: example.net

          # sans
          # format : list
          # [OPT]
          sans:
            - a.example.net
            - b.example.net

        # TLSOption
        # format : dict
        # [OPT]
        options:
          name: tlsoption
          namespace: traefikingress

        # secretName
        # format : string
        # [OPT]
        secretName: supersecret

        # TLSStore
        # format : dict
        # [OPT]
        store:
          name: tlsstore
          namespace: traefikingress


```

#### Parametre TRAEFIK ingressroutetcp

```yml
{{ include "sharedlibraries.traefik_ingressroutetcp" . }}
```


```yml
traefik:
  # -- Create TRAEFIK ingressroutetcp
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-ingressroutetcp
  # [REQ]
  ingressRouteTCP:
    - name: traefik-ingressroutetcp
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # entryPoints
      # DEF : all
      # format : list
      # [OPT]
      entryPoints:
        - web
        - websecure

      # routes
      # format : list
      # [REQ]
      routes:
          # kind
          # DEF : rule
          # [REQ]
        - kind: rule

          # match
          # format : string
          # [OPT]
          match: HostSNI(`*`)

          # services
          # DEF : list
          # [REQ]
          # DOC : https://doc.traefik.io/traefik/v2.9/routing/services/#configuring-tcp-services
          services:
            - kind: Service
              name: foo
              namespace: default

              # HELPER routes.services AdditionnalInfos
              # write as YAML (without formating or validation) everything except :
              # kind
              # name
              # namespace
              # Example valid config:
              port: 8080
              weight: 10
              terminationDelay: 400
              proxyProtocol:
                version: 1
              nativeLB: true

          # HELPER routes AdditionnalInfos
          # write as YAML (without formating or validation) everything except :
          # kind
          # match
          # services
          # Example valid config:

          # middlewares
          # DEF : list
          # [OPT]
          middlewares:
            - name: middleware1
              namespace: default

          # priority
          # format : integer
          # DEF : 0  (disable)
          # [OPT]
          priority: 0

      # HELPER ingressroutetcp AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # routes
      # entryPoints

      # tls
      # DEF : all
      # [OPT]
      tls:

        # format : string
        # NOT RECOMMANDED
        # [OPT]
        certResolver: oabresolver

        # domains
        # format : dict
        # [OPT]
        domains:

          # main
          # format : string
          # [OPT]
          main: example.net

          # sans
          # format : list
          # [OPT]
          sans:
            - a.example.net
            - b.example.net

        # TLSOption
        # format : dict
        # [OPT]
        options:
          name: tlsoption
          namespace: traefikingress

        # secretName
        # format : string
        # [OPT]
        secretName: supersecret

        # TLSStore
        # format : dict
        # [OPT]
        store:
          name: tlsstore
          namespace: traefikingress

        # passthrough
        # format : bool
        # [OPT]
        passthrough: false
```

#### Parametre TRAEFIK ingressrouteudp

```yml
{{ include "sharedlibraries.traefik_ingressrouteudp" . }}
```


```yml
traefik:
  # -- Create TRAEFIK ingressrouteudp
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-ingressrouteudp
  # [REQ]
  ingressRouteUDP:
    - name: traefik-ingressrouteudp
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # entryPoints
      # DEF : all
      # format : list
      # [OPT]
      entryPoints:
        - web
        - websecure

      # routes
      # format : list
      # [REQ]
      routes:

          # services
          # DEF : list
          # [REQ]
          # DOC : https://doc.traefik.io/traefik/v2.9/routing/services/#configuring-tcp-services
          services:
            - name: foo
              namespace: default

              # HELPER routes.services AdditionnalInfos
              # write as YAML (without formating or validation) everything except :
              # kind
              # name
              # namespace
              # Example valid config:
              port: 8080
              weight: 10

          # HELPER routes AdditionnalInfos
          # write as YAML (without formating or validation) everything except :
          # kind
          # match
          # services
          # Example valid config:

          # middlewares
          # DEF : list
          # [OPT]
          middlewares:
            - name: middleware1
              namespace: default

          # priority
          # format : integer
          # DEF : 0  (disable)
          # [OPT]
          priority: 0

      # HELPER ingressrouteudp AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # routes
      # entryPoints
```

#### Parametre TRAEFIK middleware

```yml
{{ include "sharedlibraries.traefik_middleware" . }}
```


```yml
traefik:
  # -- Create TRAEFIK middleware
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-middleware
  # DOC : https://doc.traefik.io/traefik/v2.9/middlewares/http/overview/
  # [REQ]
  middleware:
    - name: traefik-middleware
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER middleware AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
```

#### Parametre TRAEFIK middlewaretcp

```yml
{{ include "sharedlibraries.traefik_middlewaretcp" . }}
```


```yml
traefik:
  # -- Create TRAEFIK middleware
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-middleware
  # DOC : https://doc.traefik.io/traefik/v2.9/middlewares/http/overview/
  # [REQ]
  middlewareTCP:
    - name: traefik-middleware
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER middlewareTCP AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
```

#### Parametre TRAEFIK serverstransport

```yml
{{ include "sharedlibraries.traefik_serverstransport" . }}
```


```yml
traefik:
  # -- Create TRAEFIK serverstransport
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-serverstransport
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/services/#serverstransport
  # [REQ]
  serversTransport:
    - name: traefik-serverstransport
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER serverstransport AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # Example valid config:
      serverName: foobar
      insecureSkipVerify: true
      rootCAsSecrets:
        - foobar
        - foobar
      certificatesSecrets:
        - foobar
        - foobar
      maxIdleConnsPerHost: 1
      forwardingTimeouts:
        dialTimeout: 42s
        responseHeaderTimeout: 42s
        idleConnTimeout: 42s
      peerCertURI: foobar
      disableHTTP2: true
```

#### Parametre TRAEFIK tlsoptions

```yml
{{ include "sharedlibraries.traefik_tlsoptions" . }}
```


```yml
traefik:
  # -- Create TRAEFIK tlsoptions
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-tlsoption
  # DOC : https://doc.traefik.io/traefik/v2.9/https/tls/#tls-options
  # [REQ]
  tlsOptions:
    - name: traefik-tlsoptions
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER tlsoptions AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # Example valid config:
      minVersion: VersionTLS12
      maxVersion: VersionTLS13
      curvePreferences:
        - CurveP521
        - CurveP384
      cipherSuites:
        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        - TLS_RSA_WITH_AES_256_GCM_SHA384
      clientAuth:
        secretNames:
          - secret-ca1
          - secret-ca2
        clientAuthType: VerifyClientCertIfGiven
      sniStrict: true
      alpnProtocols:
        - foobar
```

#### Parametre TRAEFIK tlsstore

```yml
{{ include "sharedlibraries.traefik_tlsstore" . }}
```


```yml
traefik:
  # -- Create TRAEFIK tlsstore
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-tlsstore
  # DOC : https://doc.traefik.io/traefik/v2.9/https/tls/#certificates-stores
  # [REQ]
  tlsStore:
    - name: traefik-tlsstore
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER tlsstore AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # Example valid config:
      certificates:
        - secretName: foo
        - secretName: bar
      defaultCertificate:
        secretName: secret
```

#### Parametre TRAEFIK traefikservice

```yml
{{ include "sharedlibraries.traefik_traefikservice" . }}
```


```yml
traefik:
  # -- Create TRAEFIK traefikservice
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-traefikservice
  # DOC : https://doc.traefik.io/traefik/v2.9/routing/services/
  # [REQ]
  traefikService:
    - name: traefik-traefikservice
      namespace: traefikingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER traefikservice AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # Example valid config:
      weighted:
        services:
          - name: svc1
            port: 80
            weight: 1
          - name: wrr2
            kind: TraefikService
            weight: 1
          - name: mirror1
            kind: TraefikService
            weight: 1
      # OR :
        mirroring:
          name: svc1
          port: 80
          mirrors:
            - name: svc2
              port: 80
              percent: 20
            - name: svc3
              kind: TraefikService
              percent: 20
```


## Certificate
### CertManager
#### Parametre CertManager certificate

```yml
{{ include "sharedlibraries.certmanager_certificate" . }}
```


```yml
certManager:
  # -- Create certmanager certificate
  # DOC : https://cert-manager.io/docs/usage/certificate/
  # DOC : https://cert-manager.io/docs/concepts/certificate/
  # [REQ]
  certificate:
    - name: certmanager-certificate
      namespace: certmanageringress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # secretName
      # format : string
      # [REQ]
      secretName:

      # issuerRef
      # format : dict
      # [REQ]
      issuerRef:
        # issuerRef name
        # format : string
        # [REQ]
        name:

        # HELPER issuerRef AdditionnalInfos
        # write as YAML (without formating or validation) everything except:
        # name

      # HELPER certificate AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # secretName
      # issuerRef
```

#### Parametre CertManager issuer

```yml
{{ include "sharedlibraries.certManager_issuer" . }}
```


```yml
certManager:
  # -- Create certmanager issuer
  # DOC : https://cert-manager.io/docs/configuration/
  # DOC : https://cert-manager.io/docs/concepts/issuer/
  # [REQ]
  issuer:
    - name: certmanager-issuer
      namespace: certmanageringress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER issuer AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
```

#### Parametre CertManager clusterissuer

```yml
{{ include "sharedlibraries.certmanager_clusterissuer" . }}
```


```yml
certManager:
  # -- Create certmanager clusterissuer
  # DOC : https://cert-manager.io/docs/configuration/
  # DOC : https://cert-manager.io/docs/concepts/clusterissuer/
  # [REQ]
  clusterIssuer:
    - name: certmanager-clusterissuer
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER clusterissuer AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # additionalLabels
      # additionalAnnotations
      # syncWave
```

### StepIssuer
#### Parametre StepIssuer stepissuer

```yml
{{ include "sharedlibraries.stepissuer_stepissuer" . }}
```


```yml
stepIssuer:
  # -- Create stepissuer stepissuer
  # DOC : https://github.com/smallstep/step-issuer
  # [REQ]
  stepIssuer:
    - name: stepissuer-stepissuer
      namespace: default
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # provisioner
      # format : dict
      # [REQ]
      provisioner:

        # provisioner
        # format : string
        # [REQ]
        kid: xxxxx

        # provisioner
        # format : string
        # [REQ]
        name: test

        # provisioner
        # format : dict
        # [REQ]
        password:

          # provisioner.password.name
          # format : string
          # [REQ]
          name:

          # HELPER provisioner.password AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # name

      # url
      # format : string
      # [REQ]
      url: 'https://pki-step-certificates.outils.svc.cluster.local'

      # HELPER stepissuer AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # provisioner
      # url
```

#### Parametre StepIssuer stepclusterissuer

```yml
{{ include "sharedlibraries.stepissuer_stepclusterissuer" . }}
```


```yml

stepIssuer:
  # -- Create stepissuer stepissuer
  # DOC : https://github.com/smallstep/step-issuer
  # [REQ]
  stepClusterIssuer:
    - name: stepissuer-stepissuer
      namespace: default
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # provisioner
      # format : dict
      # [REQ]
      provisioner:

        # provisioner
        # format : string
        # [REQ]
        kid: xxxxx

        # provisioner
        # format : string
        # [REQ]
        name: test

        # provisioner
        # format : dict
        # [REQ]
        password:

          # provisioner.password.name
          # format : string
          # [REQ]
          name:

          # provisioner.password.namespace
          # format : string
          # [REQ]
          namespace:

          # HELPER provisioner.password AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # name
          # namespace

      # url
      # format : string
      # [REQ]
      url: 'https://pki-step-certificates.outils.svc.cluster.local'

      # HELPER stepissuer AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # provisioner
      # url
```


## ESO (External Secret Operator)
### Parametre ESO secretstore

```yml
{{ include "sharedlibraries.eso_secretstore" . }}
```


```yml
eso:
  # -- Create eso secretstore
  # DOC : https://external-secrets.io/v0.8.1/api/secretstore/
  # [REQ]
  secretStore:
    - name: secretstore-secretstore
      namespace: default
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # provider
      # format : dict
      # [REQ]
      provider :

        # if provider is vault
        # ELSE no validation
        # format : dict
        # [REQ]
        vault:
          # vault.auth
          # format : dict
          # [REQ]
          auth:

            # HELPER provider.vault.auth AdditionnalInfos
            # write as YAML (without formating or validation)

          # vault.server
          # format : string
          # [REQ]
          server:

          # HELPER provider.vault AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # auth
          # server

        # if another provider , no validation

      # HELPER secretstore AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # provider
```

### Parametre ESO externalsecret

```yml
{{ include "sharedlibraries.eso_externalsecret" . }}
```


```yml
eso:
  # -- Create eso externalsecret
  # DOC : https://external-secrets.io/v0.8.1/api/externalsecret/
  # [REQ]
  externalSecret:
    - name: externalsecret-externalsecret
      namespace: default
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # HELPER externalsecret AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
```


## Minio
### Parametre Minio tenant

```yml
{{ include "sharedlibraries.minio_tenant" . }}
```


```yml
minio:
  # -- Create minio tenant
  # DOC : https://github.com/smallstep/step-issuer
  # [REQ]
  tenant:
    - name: tenant-tenant
      namespace: default
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # pools
      # format : list
      # [REQ]
      pools:
        # HELPER pools AdditionnalInfos
        # write as YAML (without formating or validation)


      # HELPER tenant AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # pools
```


## Workload
### Parametre Workload  deployements

```yml
{{ include "sharedlibraries.workload_deployment" . }}
```


```yml
workload:
  # -- Create deployment
  # DOC : https://doc.workload.io/workload/v2.9/routing/providers/kubernetes-crd/#kind-deployment
  # [REQ]
  deployment:
    - name: workload-deployment
      namespace: workloadingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # selector
      # format : dict
      # [REQ]
      # All of the requirements, from both matchLabels and matchExpressions are ANDed together
      # -- they must all be satisfied in order to match
      selector:
        matchLabels:
        matchExpressions:

      # template
      # format : dict
      # [REQ]
      template:
        # HELPER template AdditionnalInfos
        # write as YAML (without formating or validation)

      # HELPER deployment AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # selector
      # template
```

### Parametre Workload  statefulsets

```yml
{{ include "sharedlibraries.workload_statefulset" . }}
```


```yml
workload:
  # -- Create statefulSet
  # DOC : https://doc.workload.io/workload/v2.9/routing/providers/kubernetes-crd/#kind-statefulSet
  # [REQ]
  statefulSet:
    - name: workload-statefulSet
      namespace: workloadingress
      additionalLabels:
      additionalAnnotations:
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # selector
      # format : dict
      # [REQ]
      # All of the requirements, from both matchLabels and matchExpressions are ANDed together
      # -- they must all be satisfied in order to match
      selector:
        matchLabels:
        matchExpressions:

      # serviceName
      # format : string
      # [REQ]
      serviceName: test

      # template
      # format : dict
      # [REQ]
      template:
        # HELPER template AdditionnalInfos
        # write as YAML (without formating or validation)

      # HELPER statefulSet AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabels
      # additionalAnnotations
      # syncWave
      # selector
      # template
```


## Secret / ConfigMap
### Parametre secret

```yml
{{ include "sharedlibraries.secret" . }}
```


```yml
secret:
  # -- Create secret
  # DOC : https://kubernetes.io/docs/concepts/configuration/secret/
  # [REQ]
  - name: secret-test
    namespace: test
    additionalLabels:
    additionalAnnotations:
    # Etape ArgoCD
    # DEF : 00
    # [OPT]
    syncWave: 00


    # type
    # format : string
    # [REQ]
    # DOC : https://kubernetes.io/docs/concepts/configuration/secret/#secret-types
    type: Opaque

    # HELPER secret AdditionnalInfos
    # write as YAML (without formating or validation) everything except:
    # name
    # namespace
    # additionalLabels
    # additionalAnnotations
    # syncWave
    # type
```

### Parametre configmap

```yml
{{ include "sharedlibraries.configmap" . }}
```


```yml
configMap:
  # -- Create configMap
  # DOC : https://kubernetes.io/docs/concepts/configuration/configMap/
  # [REQ]
  - name: configMap-test
    namespace: test
    additionalLabels:
    additionalAnnotations:
    # Etape ArgoCD
    # DEF : 00
    # [OPT]
    syncWave: 00

    # HELPER configMap AdditionnalInfos
    # write as YAML (without formating or validation) everything except:
    # name
    # namespace
    # additionalLabels
    # additionalAnnotations
    # syncWave
```


## Network
### Parametre Network services

```yml
{{ include "sharedlibraries.services" . }}
```

```yml
services:
  # -- Create services
  # DOC : https://kubernetes.io/fr/docs/concepts/services-networking/service/
  # [REQ]
  - name: svc-test
    namespace: default
    additionalLabels:
    additionalAnnotations:
    # Etape ArgoCD
    # DEF : 04
    # [OPT]
    syncWave: 04

    # type
    # DEF : all
    # format : string
    # [REQ]
    type: ClusterIP

    # ports
    # DEF : all
    # format : list
    # [REQ]
    ports:
        # ports
        # DEF : all
        # format : list
        # [REQ]
      - protocol: TCP

        # ports
        # DEF : all
        # format : list
        # [REQ]
        port: 8080

        # HELPER service.ports AdditionnalInfos
        # write as YAML (without formating or validation)

    # HELPER ingressrouteudp AdditionnalInfos
    # write as YAML (without formating or validation) everything except:
    # name
    # namespace
    # additionalLabels
    # additionalAnnotations
    # syncWave
    # type
    # ports

```

### Parametre Network networkpolicy

```yml
{{ include "sharedlibraries.networkpolicy" . }}
```

```yml
networkPolicy:
  # -- Create networkPolicy
  # DOC : https://docs.openshift.com/container-platform/4.12/networking/network_policy/about-network-policy.html
  # [REQ]
  - name: np-test
    namespace: default
    additionalLabels:
    additionalAnnotations:
    # Etape ArgoCD
    # DEF : 02
    # [OPT]
    syncWave: 02

    # podSelector
    # format : dict
    # [REQ]
    # All of the requirements, from both matchLabels and matchExpressions are ANDed together
    # -- they must all be satisfied in order to match
    podSelector:
      matchLabels:
      matchExpressions:

    # HELPER networkPolicy AdditionnalInfos
    # write as YAML (without formating or validation) everything except:
    # name
    # namespace
    # additionalLabels
    # additionalAnnotations
    # syncWave
    # podSelector
```




## Liste des template / helper des templates HELM
### Parametre template checkVariableDict

Fonction de verification des variables obligatoires dans un dictionnaire (object)

```yml
    {{/*
    ######################################
        Parametre / Values
    ######################################
      fromDict: dictionnary of input values
      masterKey : key to verify
      baseKey : base object for message output
      mandatoryKeys : list of mandatory key
    */}}
    {{- $parameterCheckDict := dict }}
    {{- $parameterCheckDictMandatoryKeys := ( list "path" "action" ) }}
    {{- $_ := set $parameterCheckDict "fromDict" $virtualServer }}
    {{- $_ := set $parameterCheckDict "masterKey" "routes" }}
    {{- $_ := set $parameterCheckDict "baseKey" "nginx.virtualServer" }}
    {{- $_ := set $parameterCheckDict "mandatoryKeys" $parameterCheckDictMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDict }}
```

### Parametre template checkVariableList

Fonction de verification des variables obligatoires dans une liste (slice)

```yml
    {{/*
    ######################################
        Parametre / Values
    ######################################
      fromDict: dictionnary of input values
      masterKey : key to verify
      baseKey : base object for message output
      mandatoryKeys : list of mandatory key
    */}}
    {{- $parameterCheckDict := dict }}
    {{- $parameterCheckDictMandatoryKeys := ( list "path" "action" ) }}
    {{- $_ := set $parameterCheckDict "fromDict" $virtualServer }}
    {{- $_ := set $parameterCheckDict "masterKey" "routes" }}
    {{- $_ := set $parameterCheckDict "baseKey" "nginx.virtualServer" }}
    {{- $_ := set $parameterCheckDict "mandatoryKeys" $parameterCheckDictMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDict }}
```

### Parametre template removeListOfKeysFromDict

Fonction qui 'print' un dictionnaire ne supprimant certaine information
Beaucoup utilisé pour valider certaine information et afficher toutes les autres.

Exemple :
```yml
  values:
    name: test
    otherInfo:
      key1: value1
```

code :
```yml
    name: {{ $values.name }}
    {{- $avoidKeys := ( list "name" ) }}
    {{- $_ := set $parameter "fromDict" $values }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $additionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $additionnalInfos }}
{{ toYaml $additionnalInfos | indent 2 }}
    {{- end }}
```

Output:

```yml
  name: test
  otherInfo:
    key1: value1
```




```yml
    {{/*
    ######################################
        Parametre / Values
    ######################################
    fromDict: dictionnary
    avoidList: list of key to remove from DICT
    */}}
    {{- $avoidKeys := ( list "name" ) }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $dict }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $additionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $additionnalInfos }}
{{ toYaml $additionnalInfos | indent 10 }}
    {{- end }}
```

### [dump](#parametre-template-dump)

Le templateing HELM est une GALERE à debug ...

Voici donc une fonction pour dump les variables

```yml
 {{/* DEBUG include "sharedlibraries.dump" $values */}}
 {{ include "sharedlibraries.dump" $values }}

```
