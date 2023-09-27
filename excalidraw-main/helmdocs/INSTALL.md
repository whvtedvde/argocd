
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
