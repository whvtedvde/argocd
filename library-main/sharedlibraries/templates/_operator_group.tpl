{{/* library template for operatorGroup definition */}}
{{- /*
BEGVAL
# -- (dict) operator
# @default -- see subconfig
# DOC: [operator](https://docs.openshift.com/container-platform/4.12/operators/understanding/olm-what-operators-are.html)
operator:
  # -- Create OPERATOR group
  # @default -- see subconfig
  ## HELPER group AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  ## ⛔ EACH Global OPERATOR must be in is own namespace to avoid delete other one
  group:
    -
      # -- (string)[REQ] name
      name: og-metallb
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
      syncWave: 00

      # -- (list)[OPT] targetNamespaces
      targetNamespaces: []

      # -- (string)[OPT] upgradeStrategy
      upgradeStrategy: Default
ENDVAL
*/}}
{{- define "sharedlibraries.operator_group" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if not $.Values.operator.group }}
    {{- fail "operator_group template loaded without operator.group object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave") }}

  {{- /*
  #################################
  LOOP all operatorGroup instance
  #################################
  */}}
  {{- range $operatorGroup := $.Values.operator.group }}
    {{- /*
    #################################
    CHECK mandatory operatorGroup values
    #################################
    */}}
    {{- /* CHECK operatorGroup.name */}}
    {{- if not $operatorGroup.name }}
      {{- fail "no name set inside operator.group object" }}
    {{- end }}

    {{- /* CHECK installplan.namespace */}}
    {{- if not $operatorGroup.namespace }}
      {{- fail "no namespace set inside operator.group object" }}
    {{- end }}

    {{- /* CHECK installplan.namespace */}}
    {{- if and ($operatorGroup.additionalLabels) (not (kindIs "map" $operatorGroup.additionalLabels)) }}
      {{- fail (printf "additionalLabels is not a DICT inside operator.group object but type is :%s" (kindOf $operatorGroup.additionalLabels)) }}
    {{- end }}

    {{- /* CHECK installplan.namespace */}}
    {{- if and ($operatorGroup.additionalAnnotations) (not (kindIs "map" $operatorGroup.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside operator.group object but type is :%s" (kindOf $operatorGroup.additionalAnnotations)) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: {{ $operatorGroup.name }}
  namespace: {{ $operatorGroup.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $operatorGroup.additionalLabels }}
{{ toYaml $operatorGroup.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "01" $operatorGroup.syncWave | squote  }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $operatorGroup.additionalAnnotations }}
{{ toYaml $operatorGroup.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
    {{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $operatorGroup }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $operatorGroupAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $operatorGroupAdditionnalInfos }}
{{ toYaml $operatorGroupAdditionnalInfos | indent 2 }}
    {{- /* END IF $operatorGroupAdditionnalInfos  */}}
    {{- end }}
...
  {{/* END RANGE */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
