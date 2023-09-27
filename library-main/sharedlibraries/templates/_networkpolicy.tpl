{{- /* library template for networkPolicy definition */}}
{{- /*
BEGVAL

# -- (dict) networkPolicy
# @default -- see subconfig
# DOC: [networkPolicy](https://docs.openshift.com/container-platform/4.12/networking/network_policy/about-network-policy.html)
networkPolicy:
  # -- Create networkPolicy
  # @default -- see subconfig
  # DOC: [networkPolicy](https://docs.openshift.com/container-platform/4.12/networking/network_policy/about-network-policy.html)
  ## HELPER networkPolicy AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, type , podSelector
  -
    # -- (string)[REQ] name
    name: np-test
    # -- (string)[REQ] namespace
    namespace: outils

    # -- (dict)[OPT] additionnal labels
    # @ignored
    additionalLabels:
      # -- (string)[OPT] additionnal labels exemple
      # @ignored
      additionalLabelsTest: test
    # -- (dict)[OPT] additionnal annotations
    # @ignored
    additionalAnnotations:
      # -- (string)[OPT] additionnal annotations exemple
      # @ignored
      additionalAnnotationsTest: test
    # -- (int)[OPT] ArgoCD syncwave annotation
    # @ignored
    syncWave: 00

    # -- (dict)[OPT] podSelector
    ## All of the requirements, from both matchLabels and matchExpressions are ANDed together
    ## they must all be satisfied in order to match.
    podSelector:
      # -- (dict)[OPT] pod labels exemple
      matchLabels:
        kubernetes.io/metadata.name: prpelna-dmz

    # -- (list)[OPT] ingress
    ingress:
      -
        # -- (list)[OPT] ports
        ports:
          -
            # -- (string)[OPT] protocol
            protocol: TCP
            # -- (int)[OPT] port
            port: 8448
    # -- (list)[OPT] policyTypes
    policyTypes:
      - Ingress
ENDVAL
*/}}
{{- define "sharedlibraries.networkpolicy" -}}

  {{- /*  Validation GENERAL */}}

  {{- /* CHECK mandatory global values  */}}

  {{- if not $.Values.networkPolicy }}
    {{- fail "networkpolicy template loaded without networkPolicy object" }}
  {{- end }}

  {{- /*  CREATE global avoid keys  */}}
  {{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*  LOOP all networkPolicy instance  */}}
  {{- range $networkPolicy := $.Values.networkPolicy }}
    {{- /* DEBUG include "sharedlibraries.dump" $networkPolicy */}}

    {{- /* CHECK mandatory networkPolicy values */}}

    {{- /* CHECK networkPolicy.name */}}
    {{- if not $networkPolicy.name }}
      {{- fail "no name set inside networkPolicy object" }}
    {{- end }}

    {{- /* CHECK networkPolicy.namespace */}}
    {{- if not $networkPolicy.namespace }}
      {{- fail "no namespace set inside networkPolicy object" }}
    {{- end }}

    {{- /* CHECK networkPolicy.additionalLabels */}}
    {{- if and ( $networkPolicy.additionalLabels ) ( not ( kindIs "map" $networkPolicy.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside networkPolicy object but type is :%s" ( kindOf $networkPolicy.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK networkPolicy.additionalAnnotations */}}
    {{- if and ( $networkPolicy.additionalAnnotations ) ( not ( kindIs "map" $networkPolicy.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside networkPolicy object but type is :%s" ( kindOf $networkPolicy.additionalAnnotations ) ) }}
    {{- end }}
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: {{ $networkPolicy.name }}
  namespace: {{ $networkPolicy.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $networkPolicy.additionalLabels }}
{{ toYaml $networkPolicy.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $networkPolicy.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $networkPolicy.additionalAnnotations }}
{{ toYaml $networkPolicy.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $networkPolicy }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $networkPolicyAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $networkPolicyAdditionnalInfos }}
{{ toYaml $networkPolicyAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
