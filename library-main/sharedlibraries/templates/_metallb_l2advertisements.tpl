{{- /* library template for MetalLB L2Advertisement definition */}}
{{- /* Parametre / Values
BEGVAL
# -- (dict) metalLB
# @default -- see subconfig
# DOC: [metalLB](https://metallb.universe.tf/)
metalLB:
  # -- Create METALLB ipPool
  # @default -- see subconfig
  ## HELPER installplan AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,ipAddressPools,ipAddressPoolSelectors,nodeSelectors
  l2Adv:
    -
      # -- (string)[REQ] name
      name: l2adv
      # -- (string)[REQ] namespace
      namespace: metallb-system

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
      syncWave: 04

      # -- (list)[REQ] ipAddressPools
      ipAddressPools:
        - ippool-test

      # -- (list)[OPT] ipAddressPoolSelectors
      ipAddressPoolSelectors:
        # -- (dict)[REQ] namespace labels with matchLabels
        matchLabels:
          # -- (string)[REQ] namespace labels example
          kubernetes.io/metadata.name: outils
        matchExpressions:

      # -- (list)[OPT] nodeSelectors
      nodeSelectors:
        # -- (dict)[REQ] namespace labels with matchLabels
        matchLabels:
          # -- (string)[REQ] namespace labels example
          kubernetes.io/metadata.name: outils
        matchExpressions:

      # -- (list)[OPT] interfaces
      ## A list of interfaces to announce from
      interfaces:
ENDVAL

*/}}
{{- define "sharedlibraries.metallb_l2advertisements" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}
  {{- if and (not $.Values.metalLB) }}
    {{- fail "metallb_l2advertisements template loaded without metalLB object" }}
  {{- end }}

  {{- if and (not $.Values.metalLB) }}
    {{- fail "metallb_l2advertisements template loaded without metalLB.l2Adv object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "ipAddressPools" "ipAddressPoolSelectors" "nodeSelectors" ) }}

  {{- /*
  #################################
  LOOP all instance
  #################################
  */}}
	{{- range $l2Adv := $.Values.metalLB.l2Adv }}
    {{- /* DEBUG include "sharedlibraries.dump" $l2Adv */}}
    {{- /*
    #################################
    CHECK mandatory l2Adv values
    #################################
    */}}
    {{- /* CHECK l2Adv.name */}}
    {{- if not $l2Adv.name }}
      {{- fail "No name set inside metalLB.l2Adv object" }}
    {{- end }}

    {{- /* CHECK l2Adv.name */}}
    {{- if not $l2Adv.namespace }}
      {{- fail "No namespace set inside metalLB.l2Adv object" }}
    {{- end }}

    {{- /* CHECK l2Adv.ipAddressPools */}}
    {{- if not $l2Adv.ipAddressPools }}
      {{- fail "No ipAddressPools set inside metalLB.l2Adv object" }}
    {{- end }}

    {{- /* CHECK l2Adv.additionalLabels */}}
    {{- if and ( $l2Adv.additionalLabels) ( not ( kindIs "map" $l2Adv.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside metalLB.l2Adv object but type is :%s" ( kindOf $l2Adv.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK l2Adv.additionalAnnotations */}}
    {{- if and ( $l2Adv.additionalAnnotations) ( not ( kindIs "map" $l2Adv.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside metalLB.l2Adv object but type is :%s" ( kindOf $l2Adv.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK CRD
    {{- if not ( $.Capabilities.APIVersions.Has "metallb.io/v1beta1" ) }}
      {{- fail ( printf "Our cluster don't have MetalLB CRD :metallb.io/v1beta1" ) }}
    {{- end }}
		*/}}

{{- /* TEMPLATE */}}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: {{ $l2Adv.name }}
  namespace: {{ $l2Adv.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $l2Adv.additionalLabels }}
{{ toYaml $l2Adv.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $l2Adv.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $l2Adv.additionalAnnotations }}
{{ toYaml $l2Adv.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  ipAddressPools: {{ toYaml $l2Adv.ipAddressPools | nindent 4 }}
    {{- if $l2Adv.ipAddressPoolSelectors }}
  ipAddressPoolSelectors: {{ toYaml $l2Adv.ipAddressPoolSelectors | nindent 4 }}
    {{- end }}
    {{- if $l2Adv.nodeSelectors  }}
  nodeSelectors: {{ toYaml $l2Adv.nodeSelectors | nindent 4 }}
    {{- end }}
    {{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $l2Adv }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $l2AdvAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $l2AdvAdditionnalInfos }}
{{ toYaml $l2AdvAdditionnalInfos | indent 2 }}
    {{- /* END IF $l2AdvAdditionnalInfos  */}}
    {{- end }}
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
