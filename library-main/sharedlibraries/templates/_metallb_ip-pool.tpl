{{- /* library template for MetalLB ipPool definition */}}
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
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,addresses,autoAssign
  ipPool:
    -
      # -- (string)[REQ] name
      name: ippool-test
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
      syncWave: 03

      # -- (list)[REQ] addresses
      addresses:
        - 172.31.164.10-172.31.164.250
        - 172.31.165.10-172.31.165.250


      # -- (bool)[OPT] autoAssign
      autoAssign: false
ENDVAL

*/}}
{{- define "sharedlibraries.metallb_ippool" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}
  {{- if and (not $.Values.metalLB) }}
    {{- fail "metallb_ippool template loaded without metalLB object" }}
  {{- end }}

  {{- if and (not $.Values.metalLB) }}
    {{- fail "metallb_ippool template loaded without metalLB.ipPool object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "addresses" "autoAssign" ) }}

  {{- /*
  #################################
  LOOP all instance
  #################################
  */}}
  {{- range $ipPool := $.Values.metalLB.ipPool }}
    {{- /* DEBUG include "sharedlibraries.dump" $ipPool */}}
    {{- /*
    #################################
    CHECK mandatory ipPool values
    #################################
    */}}
    {{- /* CHECK ipPool.name */}}
    {{- if not $ipPool.name }}
      {{- fail "No name set inside metalLB.ipPool object" }}
    {{- end }}

    {{- /* CHECK ipPool.namespace */}}
    {{- if not $ipPool.namespace }}
      {{- fail "No namespace set inside metalLB.ipPool object" }}
    {{- end }}

    {{- /* CHECK ipPool.addresses */}}
    {{- if not $ipPool.addresses }}
      {{- fail "No addresses set inside metalLB.ipPool object" }}
    {{- end }}

    {{- /* CHECK KIND ipPool.additionalLabels */}}
    {{- if and ( $ipPool.additionalLabels ) ( not ( kindIs "map" $ipPool.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside metalLB.ipPool object but type is :%s" ( kindOf $ipPool.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK KIND ipPool.additionalLabels */}}
    {{- if and ( $ipPool.additionalAnnotations ) ( not ( kindIs "map" $ipPool.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside metalLB.ipPool object but type is :%s" (kindOf $ipPool.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK CRD
    {{- if not ( $.Capabilities.APIVersions.Has "metallb.io/v1beta1" ) }}
      {{- fail ( printf "Our cluster don't have MetalLB CRD :metallb.io/v1beta1" ) }}
    {{- end }}
    */}}

{{- /* TEMPLATE */}}
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: {{ $ipPool.name }}
  namespace: {{ $ipPool.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $ipPool.additionalLabels }}
{{ toYaml $ipPool.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "03" $ipPool.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $ipPool.additionalAnnotations }}
{{ toYaml $ipPool.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  addresses:
{{ toYaml $ipPool.addresses  | indent 4 }}
    {{- if hasKey $ipPool "autoAssign" }}
      {{- if $ipPool.autoAssign }}
  autoAssign: true
      {{- else }}
  autoAssign: false
      {{- end }}
    {{- end }}
    {{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $ipPool }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $ipPoolAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $ipPoolAdditionnalInfos }}
{{ toYaml $ipPoolAdditionnalInfos | indent 2 }}
    {{- /* END IF $ipPoolAdditionnalInfos  */}}
    {{- end }}
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
