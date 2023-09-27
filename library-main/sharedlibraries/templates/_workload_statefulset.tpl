{{- /* library template for workload statefulset definition */}}
{{- /* Parametre / Values
BEGVAL
# -- (dict) workload definition
# @default -- see subconfig
workload:
  # -- (dict) Create statefulSet
  # DOC : [statefulSet](https://doc.workload.io/workload/v2.9/routing/providers/kubernetes-crd/#kind-statefulSet)
  ## HELPER statefulSet AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, selector, serviceName, template
  statefulSet:
    -
      # -- (string)[REQ] name
      name: workload-statefulSet-test
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
      syncWave: 04


      # -- (dict)[REQ] selector
      ## All of the requirements, from both matchLabels and matchExpressions are ANDed together
      ## they must all be satisfied in order to match.
      selector:
        # -- (dict)[REQ] namespace labels with matchLabels
        matchLabels:
          # -- (string)[REQ] namespace labels example
          kubernetes.io/metadata.name: outils
        matchExpressions:

      # -- (string)[REQ] serviceName
      serviceName: test


      # -- (dict)[REQ] template
      ## HELPER template AdditionnalInfos
      ## write as YAML (without formating or validation)
      template:
        test: test

ENDVAL

*/}}
{{- define "sharedlibraries.workload_statefulset" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.workload ) }}
    {{- fail "workload_statefulset template loaded without workload object" }}
  {{- end }}

  {{- if and (not $.Values.workload) }}
    {{- fail "workload_statefulset template loaded without workload.statefulSet object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "selector" "serviceName" "template" ) }}

  {{- /*
  #################################
  LOOP all statefulSet instance
  #################################
  */}}
  {{- range $statefulSet := $.Values.workload.statefulSet }}
    {{- /* DEBUG include "sharedlibraries.dump" $statefulSet */}}

    {{- /*
    #################################
    CHECK mandatory statefulSet values
    #################################
    */}}

    {{- /* CHECK statefulSet.name */}}
    {{- if not $statefulSet.name }}
      {{- fail "No name set inside workload.statefulSet object" }}
    {{- end }}

    {{- /* CHECK statefulSet.namespace */}}
    {{- if not $statefulSet.namespace }}
      {{- fail "No namespace set inside workload.statefulSet object" }}
    {{- end }}

    {{- /* CHECK statefulSet.additionalLabels */}}
    {{- if and ( $statefulSet.additionalLabels ) ( not ( kindIs "map" $statefulSet.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside workload.statefulSet object but type is :%s" ( kindOf $statefulSet.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK statefulSet.additionalAnnotations */}}
    {{- if and ( $statefulSet.additionalAnnotations ) ( not ( kindIs "map" $statefulSet.additionalAnnotations  ) ) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside workload.statefulSet object but type is :%s" ( kindOf $statefulSet.additionalAnnotations  ) ) }}
    {{- end }}

    {{- /* CHECK statefulSet.selector */}}
    {{- if not $statefulSet.selector }}
      {{- fail "No selector set inside workload.statefulSet object" }}
    {{- end }}

    {{- /* CHECK statefulSet.selector.matchLabels or statefulSet.selector.matchExpressions */}}
    {{- if and ( not $statefulSet.selector.matchLabels ) ( not $statefulSet.selector.matchExpressions ) }}
      {{- fail "No matchLabels and/or matchExpressions set inside workload.statefulSet.selector object" }}
    {{- end }}

    {{- /* CHECK statefulSet.serviceName */}}
    {{- if not $statefulSet.serviceName  }}
      {{- fail "No serviceName  set inside workload.statefulSet object" }}
    {{- end }}

    {{- /* CHECK statefulSet.template */}}
    {{- if not $statefulSet.template }}
      {{- fail "No template set inside workload.statefulSet object" }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $statefulSet.name }}
  namespace: {{ $statefulSet.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $statefulSet.additionalLabels }}
{{ toYaml $statefulSet.additionalLabels | indent 4 }}
    {{- /* END IF statefulSet.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $statefulSet.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $statefulSet.additionalAnnotations }}
{{ toYaml $statefulSet.additionalAnnotations | indent 4 }}
    {{- /* END IF statefulSet.additionalAnnotations */}}
    {{- end }}
spec:
  selector:
{{ toYaml $statefulSet.selector | indent 4 }}
  serviceName : {{ $statefulSet.serviceName }}
  template:
    {{- $parameterStatefulSetTemplate := dict }}
    {{- $avoidKeysDeplomentTemplate := list }}
    {{- $_ := set $parameterStatefulSetTemplate "fromDict" $statefulSet.template }}
    {{- $_ := set $parameterStatefulSetTemplate "avoidList" $avoidKeysDeplomentTemplate }}
    {{- $statefulSetTemplateAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterStatefulSetTemplate ) }}
    {{- if $statefulSetTemplateAdditionnalInfos }}
{{ toYaml $statefulSetTemplateAdditionnalInfos | indent 4 }}
    {{- /* END IF statefulSetTemplateAdditionnalInfos */}}
    {{- end }}
    {{- $parameterstatefulSet := dict }}
    {{- $_ := set $parameterstatefulSet "fromDict" $statefulSet }}
    {{- $_ := set $parameterstatefulSet "avoidList" $avoidKeys }}
    {{- $statefulSetAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterstatefulSet ) }}
    {{- if $statefulSetAdditionnalInfos }}
{{ toYaml $statefulSetAdditionnalInfos | indent 2 }}
    {{- /* END IF statefulSetAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE statefulSet */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
