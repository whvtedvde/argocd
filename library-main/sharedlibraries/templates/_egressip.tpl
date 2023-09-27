{{- /*  library template for egressIp definition */}}
{{- /*
BEGVAL

# -- (dict) EgressIP definition
# @default -- see subconfig
# DOC: [openshift egress](https://docs.openshift.com/container-platform/4.12/networking/ovn_kubernetes_network_provider/configuring-egress-ips-ovn.html)
egressIp:
  -
    # -- (string)[REQ] egressIp name
    name: egressip-test

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
    syncWave: 02

    # -- (list)[REQ] Ensemble des IPs alloué à l'egress
    egressIPs:
    - 192.168.5.5
    - 192.168.6.6

    # -- (dict)[REQ] namespaceSelector
    ## All of the requirements, from both matchLabels and matchExpressions are ANDed together
    ## they must all be satisfied in order to match.
    namespaceSelector:
      # -- (dict)[REQ] namespace labels with matchLabels
      matchLabels:
        # -- (string)[REQ] namespace labels example
        kubernetes.io/metadata.name: outils
      matchExpressions:

    # -- (dict)[OPT] podSelector
    ## All of the requirements, from both matchLabels and matchExpressions are ANDed together
    ## they must all be satisfied in order to match.
    podSelector:
      # -- (dict)[OPT] pod labels exemple
      matchLabels:
        620nm.net/egressip: prptlfbo

ENDVAL
*/}}

{{- define "sharedlibraries.egressip" -}}
  {{- /* Validation GENERAL */}}

  {{- /*  CHECK $.Values.egressIp  */}}
  {{- if and ( not $.Values.egressIp ) }}
    {{- fail "egressip template loaded without egressIp object" }}
  {{- end }}

	{{- /*  LOOP all egressIp instance */}}
  {{- range $egressIp := $.Values.egressIp }}
    {{- /*  DEBUG include "sharedlibraries.dump" $egressIp */}}

    {{- /* CHECK $egressIp.name */}}
    {{- if not $egressIp.name }}
      {{- fail "No name set inside egressIp object" }}
    {{- end }}

    {{- /* CHECK $egressIp.egressIPs */}}
    {{- if not $egressIp.egressIPs }}
      {{- fail "No egressIPs set inside egressIp object" }}
    {{- end }}

    {{- /* CHECK $egressIp.namespaceSelector */}}
    {{- if not $egressIp.namespaceSelector }}
      {{- fail "No namespaceSelector set inside egressIp object" }}
    {{- end }}

    {{- /* CHECK $egressIp.namespaceSelector matchLabels and/or matchExpressions  */}}
    {{- if and (not $egressIp.namespaceSelector.matchLabels) (not $egressIp.namespaceSelector.matchExpressions) }}
      {{- fail "No matchLabels and/or matchExpressions set inside egressIp.namespaceSelector object" }}
    {{- end }}

    {{- /* CHECK $egressIp.additionalLabels */}}
    {{- if and ($egressIp.additionalLabels) (not (kindIs "map" $egressIp.additionalLabels)) }}
      {{- fail (printf "additionalLabels is not a DICT inside metalLB.egressIp object but type is :%s" (kindOf $egressIp.additionalLabels)) }}
    {{- end }}

    {{- /* CHECK $egressIp.additionalAnnotations */}}
    {{- if and ($egressIp.additionalAnnotations) (not (kindIs "map" $egressIp.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside metalLB.egressIp object but type is :%s" (kindOf $egressIp.additionalAnnotations)) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: k8s.ovn.org/v1
kind: EgressIP
metadata:
  name: {{ $egressIp.name }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $egressIp.additionalLabels }}
{{ toYaml $egressIp.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "02" $egressIp.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $egressIp.additionalAnnotations }}
{{ toYaml $egressIp.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  egressIPs:
{{ toYaml $egressIp.egressIPs | indent 4 }}
  namespaceSelector:
{{ toYaml $egressIp.namespaceSelector | indent 4 }}
    {{- if $egressIp.podSelector }}
  podSelector:
{{ toYaml $egressIp.podSelector | indent 4  }}
    {{- end }}
...
  {{- /*  END RANGE */}}
  {{- end }}
{{- /*  END DEFINE */}}
{{- end -}}
