{{/* library template for secret definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################

# -- (dict) secret
# @default -- see subconfig
# DOC: [secret](https://docs.openshift.com/container-platform/4.12/nodes/pods/nodes-pods-secrets.html)
secret:
  # -- Create secret
  # @default -- see subconfig
  # DOC : [secret](https://kubernetes.io/docs/concepts/configuration/secret/)
  ## HELPER secret AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,type
  -
    # -- (string)[REQ] name
    name: secret-test
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


    # -- (string)[REQ] type
    # DOC : [secret-types](https://kubernetes.io/docs/concepts/configuration/secret/#secret-types)
    type: Opaque

    # -- (string)[OPT] type
    immutable: false
    # -- (dict)[OPT] data
    data:
      test: wxxxxxxxxxxxxxxxx



*/}}
{{- define "sharedlibraries.secret" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.secret  */}}
  {{- if and (not $.Values.secret) }}
    {{- fail "secret template loaded without secret object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "type" ) }}
  {{- range $secret := $.Values.secret }}
    {{/* DEBUG include "sharedlibraries.dump" $secret */}}
    {{/*
    ######################################
    Validation Mandatory Variables Secret
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $secret.name
    ######################################
    */}}
    {{- if not $secret.name }}
      {{- fail "No name set inside secret object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $secret.namespace
    ######################################
    */}}
    {{- if not $secret.namespace }}
      {{- fail "No namespace set inside secret object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $secret.additionalLabels
    ######################################
    */}}
    {{- if and ($secret.additionalLabels) (not (kindIs "map" $secret.additionalLabels)) }}
      {{- fail (printf "additionalLabels is not a DICT inside secret object but type is :%s" (kindOf $secret.additionalLabels)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $secret.additionalAnnotations
    ######################################
    */}}
    {{- if and ($secret.additionalAnnotations) (not (kindIs "map" $secret.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside secret object but type is :%s" (kindOf $secret.additionalAnnotations)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK $secret.type
    ######################################
    */}}
    {{- if not $secret.type }}
      {{- fail "No type set inside secret object" }}
    {{- end }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ $secret.name }}
  namespace: {{ $secret.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $secret.additionalLabels }}
{{ toYaml $secret.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "02" $secret.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $secret.additionalAnnotations }}
{{ toYaml $secret.additionalAnnotations | indent 4 }}
    {{- end }}
type: {{ $secret.type }}
    {{- $parameterSecret := dict }}
    {{- $_ := set $parameterSecret "fromDict" $secret }}
    {{- $_ := set $parameterSecret "avoidList" $avoidKeys }}
    {{- $secretAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterSecret ) }}
    {{- if $secretAdditionnalInfos }}
{{ toYaml $secretAdditionnalInfos | indent 0 }}
    {{/* END IF secretAdditionnalInfos */}}
    {{- end }}
...
  {{/* END RANGE */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
