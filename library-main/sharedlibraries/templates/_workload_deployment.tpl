{{/* library template for workload deployment definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################

# -- (dict) workload definition
# @default -- see subconfig
workload:
  # -- (dict) Create deployment
  # DOC : [deployment](https://doc.workload.io/workload/v2.9/routing/providers/kubernetes-crd/#kind-deployment)
  ## HELPER deployment AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, selector, template
  deployment:
    -
      # -- (string)[REQ] name
      name: workload-deployment-test
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

      # -- (string)[OPT] How many Pod should be created
      # @ignored
      # @default 1
      replicas: 1

      # -- (string)[OPT] How many version of deployment to keep
      # @ignored
      # @default 5
      revisionHistoryLimit: 5
      
      # -- (dict)[REQ] selector
      ## All of the requirements, from both matchLabels and matchExpressions are ANDed together
      ## they must all be satisfied in order to match.
      selector:
        # -- (dict)[REQ] namespace labels with matchLabels
        matchLabels:
          # -- (string)[REQ] namespace labels example
          kubernetes.io/metadata.name: outils
        matchExpressions:

      # -- (dict)[REQ] template
      ## HELPER template AdditionnalInfos
      ## write as YAML (without formating or validation)
      template:
        test: test

*/}}
{{- define "sharedlibraries.workload_deployment" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.workload  */}}
  {{- if and ( not $.Values.workload ) }}
    {{- fail "workload_deployment template loaded without workload object" }}
  {{- end }}
  {{/* CHECK $.Values.workload.deployment  */}}
  {{- if and (not $.Values.workload) }}
    {{- fail "workload_deployment template loaded without workload.deployment object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "selector" "template" ) }}
  {{- range $deployment := $.Values.workload.deployment }}
    {{/* DEBUG include "sharedlibraries.dump" $deployment */}}
    {{/*
    ######################################
    Validation Mandatory Variables deployment
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $deployment.name
    ######################################
    */}}
    {{- if not $deployment.name }}
      {{- fail "No name set inside workload.deployment object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $deployment.namespace
    ######################################
    */}}
    {{- if not $deployment.namespace }}
      {{- fail "No namespace set inside workload.deployment object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $deployment.additionalLabels
    ######################################
    */}}
    {{- if and ( $deployment.additionalLabels ) ( not (kindIs "map" $deployment.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside workload.deployment object but type is :%s" ( kindOf $deployment.additionalLabels )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $deployment.additionalAnnotations
    ######################################
    */}}
    {{- if and ($deployment.additionalAnnotations) (not (kindIs "map" $deployment.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside workload.deployment object but type is :%s" ( kindOf $deployment.additionalAnnotations )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK $deployment.selector
    ######################################
    */}}
    {{- if not $deployment.selector }}
      {{- fail "No selector set inside deployment object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $deployment.selector.matchLabels and/or matchExpressions
    ######################################
    */}}
    {{- if and (not $deployment.selector.matchLabels) (not $deployment.selector.matchExpressions) }}
      {{- fail "No matchLabels and/or matchExpressions set inside deployment.selector object" }}
    {{- end }}

    {{/*
    ######################################
    CHECK $deployment.template
    ######################################
    */}}
    {{- if not $deployment.template }}
      {{- fail "No template set inside deployment object" }}
    {{- end }}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $deployment.name }}
  namespace: {{ $deployment.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $deployment.additionalLabels }}
{{ toYaml $deployment.additionalLabels | indent 4 }}
    {{/* END IF deployment.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $deployment.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $deployment.additionalAnnotations }}
{{ toYaml $deployment.additionalAnnotations | indent 4 }}
    {{/* END IF deployment.additionalAnnotations */}}
    {{- end }}
spec:
  replicas: {{ $deployment.replicas | default 1 }}
  revisionHistoryLimit: {{ $deployment.revisionHistoryLimit | default 5 }}
  selector:
{{ toYaml $deployment.selector | indent 4 }}
  template:
    {{- $parameterDeploymentTemplate := dict }}
    {{- $avoidKeysDeplomentTemplate := list }}
    {{- $_ := set $parameterDeploymentTemplate "fromDict" $deployment.template }}
    {{- $_ := set $parameterDeploymentTemplate "avoidList" $avoidKeysDeplomentTemplate }}
    {{- $deploymentTemplateAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterDeploymentTemplate ) }}
    {{- if $deploymentTemplateAdditionnalInfos }}
{{ toYaml $deploymentTemplateAdditionnalInfos | indent 4 }}
    {{/* END IF deploymentTemplateAdditionnalInfos */}}
    {{- end }}
    {{- $parameterdeployment := dict }}
    {{- $_ := set $parameterdeployment "fromDict" $deployment }}
    {{- $_ := set $parameterdeployment "avoidList" $avoidKeys }}
    {{- $deploymentAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterdeployment ) }}
    {{- if $deploymentAdditionnalInfos }}
{{ toYaml $deploymentAdditionnalInfos | indent 2 }}
    {{/* END IF deploymentAdditionnalInfos */}}
    {{- end }}
...
  {{/* END RANGE deployment */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
