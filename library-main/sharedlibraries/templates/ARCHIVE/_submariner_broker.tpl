{{/* library template for Submariner Broker definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################
submariner:
  broker:
    components:
      - service-discovery
      - connectivity
    defaultGlobalnetClusterSize: 65536
    globalnetCIDRRange: 242.0.0.0/8
    globalnetEnabled: true
*/}}
{{- define "sharedlibraries.submariner_broker" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.submariner.broker  */}}
  {{- if not $.Values.submariner }}
    {{- fail "submariner_broker template loaded without submariner object" }}
  {{- end }}
  {{- if not $.Values.submariner.broker }}
    {{- fail "submariner_broker template loaded without submariner.broker object" }}
  {{- end }}
  {{/*
  ######################################
  Prepare list to push other information
  ######################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabel" "additionalAnnotations" "components" "syncWave" ) }}
  {{- range $submarinerBroker := $.Values.submariner.broker }}
    {{/* DEBUG include "sharedlibraries.dump" $submarinerBroker */}}
    {{/*
    ######################################
    Validation Mandatory Variables submarinerBroker
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $submarinerBroker.name
    ######################################
    */}}
    {{- if not $submarinerBroker.name }}
      {{- fail "no name set inside submariner.broker object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerBroker.namespace
    ######################################
    */}}
    {{- if not $submarinerBroker.namespace }}
      {{- fail "no namespace set inside submariner.broker object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $submarinerBroker.additionalLabels
    ######################################
    */}}
    {{- if and ($submarinerBroker.additionalLabels) (not (kindIs "map" $submarinerBroker.additionalLabels)) }}
      {{- fail (printf "additionalLabels is not a DICT inside submariner.broker object but type is :%s" (kindOf $submarinerBroker.additionalLabels)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $submarinerBroker.additionalAnnotations
    ######################################
    */}}
    {{- if and ($submarinerBroker.additionalAnnotations) (not (kindIs "map" $submarinerBroker.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside submariner.broker object but type is :%s" (kindOf $submarinerBroker.additionalAnnotations)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerBroker.components
    ######################################
    */}}
    {{- if not $submarinerBroker.components }}
      {{- fail "no components set inside submariner.broker object" }}
    {{- end }}
---
apiVersion: submariner.io/v1alpha1
kind: Broker
metadata:
    {{- if hasPrefix "broker-" $submarinerBroker.name }}
  name: {{ $submarinerBroker.name }}
    {{- else }}
  name: {{ printf "broker-%s" $submarinerBroker.name }}
    {{- end }}
  namespace: {{ $submarinerBroker.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $submarinerBroker.additionalLabels }}
{{ toYaml $submarinerBroker.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $submarinerBroker.syncWave | squote  }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $submarinerBroker.additionalAnnotations }}
{{ toYaml $submarinerBroker.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  components:
{{ toYaml $submarinerBroker.components | indent 4 }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $submarinerBroker }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $submarinerBrokerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $submarinerBrokerAdditionnalInfos }}
{{ toYaml $submarinerBrokerAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{/* END RANGE */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
