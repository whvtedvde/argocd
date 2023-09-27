
# excalidraw

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 0.6.20](https://img.shields.io/badge/AppVersion-0.6.20-informational?style=flat-square)
<br>
[![sharedlibraries](https://flat.badgen.net/badge/sharedlibraries/enabled/blue?icon=libraries)](https://git-oab.si.fr.intraorange/equipe-papf/openshift_argocd/library/-/tree/main/sharedlibraries)
[![precommit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&style=flat-square)](https://github.com/pre-commit/pre-commit)
[![helmdocs](https://flat.badgen.net/badge/helm-docs/enabled/pink?icon=https://media.flaticon.com/dist/min/img/landing/gsuite/docs.svg)](https://github.com/norwoodj/helm-docs)
<br>
## Deployed ON :

- prp.vdr : [![prp.vdr](https://openshift-gitops-server-openshift-gitops.apps.paiprp.620nm.net/api/badge?name=excalidraw)](https://openshift-gitops-server-openshift-gitops.apps.paiprp.620nm.net/applications/openshift-gitops/excalidraw)

________________

> Installation de excalidraw
>
>

## Table Of Content

[[_TOC_]]

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Nicolas SIMON | <nicolas.simon@orange.com> | <https://git-oab.si.fr.intraorange/JSGH7320> |

## Installation

### HELM

*Exemple pour la PRP VDR*
Inside chart folder:

```console
helm dependency update .
helm install . -f values-excalidraw.yaml
```

### ARGOCD Application Set

*Exemple pour la PRP VDR*
Inside chart folder:
```console
argocd login XXXXX
argocd repo get "https://multirepo-oab.si.fr.intraorange/artifactory/helm-EQUIPE_PAPF"
argocd repo get "https://git-oab.si.fr.intraorange/equipe-papf/openshift_argocd/cluster-ops/excalidraw.git"
argocd appset create ApplicationSet.yaml
argocd app get openshift-gitops/excalidraw --hard-refresh
argocd app sync openshift-gitops/excalidraw
```

### ApplicationSet file

<details><summary>show</summary>

```yml
# yamllint disable rule:line-length rule:comments-indentation
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: appset-excalidraw
  namespace: openshift-gitops
spec:
  generators:
    - clusters:
        selector:
          matchLabels:
            env: prp
            dc: vdr
        values:
          clustername: prp-vdr
          applicationname: excalidraw
  template:
    metadata:
      name: '{{values.applicationname}}'
    spec:
      project: default
      source:
        repoURL: https://git-oab.si.fr.intraorange/equipe-papf/openshift_argocd/cluster-ops/excalidraw.git
        targetRevision: HEAD
        path: .
        helm:
          ignoreMissingValueFiles: true
          valueFiles:
            - values-{{values.applicationname}}.yaml  # Simple instance default values
            - values-{{values.applicationname}}-{{values.clustername}}.yaml  # Simple instance values for one cluster
      destination:
        server: '{{server}}'
...

```

</details>

## Values Communes

<table >
  <thead>
    <th>Key</th>
    <th>Type</th>
    <th>REQ</th>
    <th>Description</th>
    <th>Default</th>
  </thead>
  <tbody>
    <tr>
      <td><div id="certManager--certificate"><a href="./values-excalidraw.yaml#L117">certManager.<wbr>certificate</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td><wbr>excalidraw <wbr>certificate <wbr><br>DOC <wbr>: <wbr>[certificate](https://cert-manager.io/docs/concepts/certificate/)</td>
      <td>
<pre>
see subconfig
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="certManager--certificate[0]--Name"><a href="./values-excalidraw.yaml#L138">certManager.<wbr>certificate[0].<wbr>Name</a></div></td>
      <td>string</td>
      <td>YES <br> 🟢</td>
      <td><wbr>Certificate <wbr>CN</td>
      <td>
<pre>
"excalidraw.outils.paiprp.620nm.net"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="certManager--certificate[0]--dnsNames"><a href="./values-excalidraw.yaml#L140">certManager.<wbr>certificate[0].<wbr>dnsNames</a></div></td>
      <td>string</td>
      <td>YES <br> 🟢</td>
      <td><wbr>Certificate <wbr>DNS</td>
      <td>
<pre>
[]
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="certManager--certificate[0]--duration"><a href="./values-excalidraw.yaml#L150">certManager.<wbr>certificate[0].<wbr>duration</a></div></td>
      <td>string</td>
      <td>YES <br> 🟢</td>
      <td><wbr>Certificate <wbr>duration</td>
      <td>
<pre>
"48h0m0s"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="certManager--certificate[0]--ipAddresses"><a href="./values-excalidraw.yaml#L145">certManager.<wbr>certificate[0].<wbr>ipAddresses</a></div></td>
      <td>string</td>
      <td>YES <br> 🟢</td>
      <td><wbr>Certificate <wbr>IPs</td>
      <td>
<pre>
[]
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="certManager--certificate[0]--issuerRef"><a href="./values-excalidraw.yaml#L130">certManager.<wbr>certificate[0].<wbr>issuerRef</a></div></td>
      <td>dict</td>
      <td>YES <br> 🟢</td>
      <td><wbr>Which <wbr>issuer <wbr>to <wbr>used <wbr><br> <wbr>Use <wbr>step <wbr>cluster <wbr>issuer <wbr>with <wbr>self-hosted <wbr>StepCA</td>
      <td>
<p>
<details>
<summary>show</summary>

```json
{}
```
</details>
</p>
      </td>
    </tr>
    <tr>
      <td><div id="certManager--certificate[0]--privateKey"><a href="./values-excalidraw.yaml#L152">certManager.<wbr>certificate[0].<wbr>privateKey</a></div></td>
      <td>dict</td>
      <td>YES <br> 🟢</td>
      <td><wbr>Certificate <wbr>Crypto</td>
      <td>
<p>
<details>
<summary>show</summary>

```json
{}
```
</details>
</p>
      </td>
    </tr>
    <tr>
      <td><div id="certManager--certificate[0]--renewBefore"><a href="./values-excalidraw.yaml#L160">certManager.<wbr>certificate[0].<wbr>renewBefore</a></div></td>
      <td>string</td>
      <td>YES <br> 🟢</td>
      <td><wbr>Certificate <wbr>Renew <wbr>before <wbr>expiration</td>
      <td>
<pre>
"8h0m0s"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="certManager--certificate[0]--secretName"><a href="./values-excalidraw.yaml#L127">certManager.<wbr>certificate[0].<wbr>secretName</a></div></td>
      <td>string</td>
      <td>YES <br> 🟢</td>
      <td><wbr>secret <wbr>to <wbr>save <wbr>Certificate</td>
      <td>
<pre>
"secret-certmanager-certificate-excalidraw"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="services"><a href="./values-excalidraw.yaml#L85">services</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td><wbr>excalidraw <wbr>services</td>
      <td>
<pre>
see subconfig
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="services[0]--ports"><a href="./values-excalidraw.yaml#L99">services[0].<wbr>ports</a></div></td>
      <td>list</td>
      <td>YES <br> 🟢</td>
      <td><wbr>set <wbr>ports</td>
      <td>
<p>
<details>
<summary>show</summary>

```json
[
  {}
]
```
</details>
</p>
      </td>
    </tr>
    <tr>
      <td><div id="services[0]--selector"><a href="./values-excalidraw.yaml#L110">services[0].<wbr>selector</a></div></td>
      <td>dict</td>
      <td>YES <br> 🟢</td>
      <td><wbr>selector <wbr>pod</td>
      <td>
<p>
<details>
<summary>show</summary>

```json
{}
```
</details>
</p>
      </td>
    </tr>
    <tr>
      <td><div id="traefik--ingressRoute"><a href="./values-excalidraw.yaml#L165">traefik.<wbr>ingressRoute</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td><wbr>excalidraw <wbr>Traefik <wbr>ingressRoute <wbr><br>DOC <wbr>: <wbr>[Traefik](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/)</td>
      <td>
<pre>
see subconfig
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="traefik--ingressRoute[0]--additionalAnnotations--"kubernetes--io/ingress--class""><a href="./values-excalidraw.yaml#L173">traefik.<wbr>ingressRoute[0].<wbr>additionalAnnotations.<wbr>"kubernetes.<wbr>io/ingress.<wbr>class"</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td><wbr>Annotation <wbr>to <wbr>set <wbr>which <wbr>traefik <wbr>ingress <wbr>to <wbr>use</td>
      <td>
<pre>
"traefik-outils-dmz"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="traefik--ingressRoute[0]--entryPoints"><a href="./values-excalidraw.yaml#L183">traefik.<wbr>ingressRoute[0].<wbr>entryPoints</a></div></td>
      <td>dict</td>
      <td>YES <br> 🟢</td>
      <td><wbr>entryPoints <wbr><br> <wbr>Get <wbr>traffic <wbr>via <wbr>HTTPS</td>
      <td>
<p>
<details>
<summary>show</summary>

```json
[
  "websecure"
]
```
</details>
</p>
      </td>
    </tr>
    <tr>
      <td><div id="traefik--ingressRoute[0]--routes[0]--match"><a href="./values-excalidraw.yaml#L190">traefik.<wbr>ingressRoute[0].<wbr>routes[0].<wbr>match</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td><wbr>Which <wbr>parameter <wbr>take <wbr>care <wbr>of <wbr>flow</td>
      <td>
<pre>
"Host(`excalidraw.outils.paiprp.620nm.net`)"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="traefik--ingressRoute[0]--routes[0]--services"><a href="./values-excalidraw.yaml#L192">traefik.<wbr>ingressRoute[0].<wbr>routes[0].<wbr>services</a></div></td>
      <td>list</td>
      <td>YES <br> 🟢</td>
      <td><wbr>Backend <wbr>config</td>
      <td>
<p>
<details>
<summary>show</summary>

```json
[
  {}
]
```
</details>
</p>
      </td>
    </tr>
    <tr>
      <td><div id="traefik--ingressRoute[0]--tls"><a href="./values-excalidraw.yaml#L207">traefik.<wbr>ingressRoute[0].<wbr>tls</a></div></td>
      <td>dict</td>
      <td>NO <br> 🔴</td>
      <td><wbr>Get <wbr>Cert-Manager <wbr>TLS <wbr>certificate <wbr>from <wbr>secret</td>
      <td>
<p>
<details>
<summary>show</summary>

```json
{}
```
</details>
</p>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--name"><a href="./values-excalidraw.yaml#L60">workload.<wbr>deployment[0].<wbr>name</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"workload-deployment-excalidraw"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--namespace"><a href="./values-excalidraw.yaml#L61">workload.<wbr>deployment[0].<wbr>namespace</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"outils"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--selector--matchLabels--"app--kubernetes--io/name""><a href="./values-excalidraw.yaml#L65">workload.<wbr>deployment[0].<wbr>selector.<wbr>matchLabels.<wbr>"app.<wbr>kubernetes.<wbr>io/name"</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"excalidraw"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--syncWave"><a href="./values-excalidraw.yaml#L62">workload.<wbr>deployment[0].<wbr>syncWave</a></div></td>
      <td>int</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
1
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--metadata--labels--"app--kubernetes--io/name""><a href="./values-excalidraw.yaml#L69">workload.<wbr>deployment[0].<wbr>template.<wbr>metadata.<wbr>labels.<wbr>"app.<wbr>kubernetes.<wbr>io/name"</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"excalidraw"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--containers[0]--image"><a href="./values-excalidraw.yaml#L79">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>containers[0].<wbr>image</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"excalidraw/excalidraw:latest"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--containers[0]--imagePullPolicy"><a href="./values-excalidraw.yaml#L77">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>containers[0].<wbr>imagePullPolicy</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"IfNotPresent"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--containers[0]--name"><a href="./values-excalidraw.yaml#L73">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>containers[0].<wbr>name</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"excalidraw"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--containers[0]--ports[0]--containerPort"><a href="./values-excalidraw.yaml#L75">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>containers[0].<wbr>ports[0].<wbr>containerPort</a></div></td>
      <td>int</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
80
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--containers[0]--ports[0]--protocol"><a href="./values-excalidraw.yaml#L76">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>containers[0].<wbr>ports[0].<wbr>protocol</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"TCP"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--containers[0]--terminationMessagePolicy"><a href="./values-excalidraw.yaml#L78">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>containers[0].<wbr>terminationMessagePolicy</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"File"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--securityContext--runAsUser"><a href="./values-excalidraw.yaml#L81">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>securityContext.<wbr>runAsUser</a></div></td>
      <td>int</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
0
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--serviceAccount"><a href="./values-excalidraw.yaml#L82">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>serviceAccount</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"sa-excalidraw"
</pre>
      </td>
    </tr>
    <tr>
      <td><div id="workload--deployment[0]--template--spec--serviceAccountName"><a href="./values-excalidraw.yaml#L71">workload.<wbr>deployment[0].<wbr>template.<wbr>spec.<wbr>serviceAccountName</a></div></td>
      <td>string</td>
      <td>NO <br> 🔴</td>
      <td>none</td>
      <td>
<pre>
"sa-excalidraw"
</pre>
      </td>
    </tr>
  </tbody>
</table>

## Extra Rendered

## Rendered Communes :

<details><summary>show</summary>

```yml
# yamllint disable rule:line-length rule:comments-indentation
---
# Source: excalidraw/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-excalidraw
  namespace: outils
  labels:
    release: release-name
    heritage: Helm
    app.kubernetes.io/name: excalidraw
  annotations:
    argocd.argoproj.io/sync-wave: '-5'
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: release-name
...
---
# Source: excalidraw/templates/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: r-excalidraw
  namespace: outils-dmz
  labels:
    release: release-name
    heritage: Helm
    app.kubernetes.io/name: excalidraw
  annotations:
    argocd.argoproj.io/sync-wave: '-5'
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: release-name
rules:
  - apiGroups:
    - cert-manager.io
    resources:
    - certificates
    verbs:
    - '*'
...
---
# Source: excalidraw/templates/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-sa-gitops-to-excalidraw
  namespace: outils-dmz
  labels:
    release: release-name
    heritage: Helm
  annotations:
    argocd.argoproj.io/sync-wave: '-4'
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: release-name
subjects:
  - kind: ServiceAccount
    name: openshift-gitops-argocd-application-controller
    namespace: openshift-gitops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: r-excalidraw
...
---
# Source: excalidraw/templates/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-sa-excalidraw-to-privileged
  namespace: outils
  labels:
    release: release-name
    heritage: Helm
  annotations:
    argocd.argoproj.io/sync-wave: '-4'
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: release-name
subjects:
  - kind: ServiceAccount
    name: sa-excalidraw
    namespace: outils
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:openshift:scc:privileged
...
---
# Source: excalidraw/templates/services.yaml
kind: Service
apiVersion: v1
metadata:
  name: svc-excalidraw
  namespace: outils
  labels:
    release: release-name
    heritage: Helm
    app.kubernetes.io/name: excalidraw
  annotations:
    argocd.argoproj.io/sync-wave: '2'
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: release-name
spec:
  type: ClusterIP
  ports:
    - name: web-excalidraw
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app.kubernetes.io/name: excalidraw
...
---
# Source: excalidraw/templates/workload_deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: workload-deployment-excalidraw
  namespace: outils
  labels:
    release: release-name
    heritage: Helm
  annotations:
    argocd.argoproj.io/sync-wave: '1'
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: release-name
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: excalidraw
  template:
    metadata:
      labels:
        app.kubernetes.io/name: excalidraw
    spec:
      containers:
      - image: excalidraw/excalidraw:latest
        imagePullPolicy: IfNotPresent
        name: excalidraw
        ports:
        - containerPort: 80
          protocol: TCP
        terminationMessagePolicy: File
      securityContext:
        runAsUser: 0
      serviceAccount: sa-excalidraw
      serviceAccountName: sa-excalidraw
...
---
# Source: excalidraw/templates/certmanager_certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: certmanager-certificate-excalidraw
  namespace: outils-dmz
  labels:
    release: release-name
    heritage: Helm
  annotations:
    argocd.argoproj.io/sync-wave: '2'
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: release-name
spec:
  secretName: secret-certmanager-certificate-excalidraw
  issuerRef:
    name: stepissuer-stepclusterissuer
    group: certmanager.step.sm
    kind: StepClusterIssuer
  commonName: excalidraw.outils.paiprp.620nm.net
  dnsNames:
  - excalidraw.outils.paiprp.620nm.net
  duration: 48h0m0s
  ipAddresses:
  - 10.222.1.20
  privateKey:
    algorithm: RSA
    rotationPolicy: Always
    size: 4096
  renewBefore: 8h0m0s
...
---
# Source: excalidraw/templates/traefik_ingressroute.yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-ingressroute-excalidraw
  namespace: outils-dmz
  labels:
    release: release-name
    heritage: Helm
  annotations:
    argocd.argoproj.io/sync-wave: '3'
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: release-name
    gethomepage.dev/description: excalidraw
    gethomepage.dev/enabled: "true"
    gethomepage.dev/group: Outils PAPF
    gethomepage.dev/href: https://excalidraw.outils.paiprp.620nm.net/
    gethomepage.dev/icon: excalidraw.svg
    gethomepage.dev/name: excalidraw
    kubernetes.io/ingress.class: traefik-outils-dmz
spec:
  tls:
    secretName: secret-certmanager-certificate-excalidraw
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host(`excalidraw.outils.paiprp.620nm.net`)
      services:
        - kind: Service
          name: svc-excalidraw
          namespace: outils
          passHostHeader: true
          port: 80
          scheme: http
...

```

</details>

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
