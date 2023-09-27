{{/* library template helper nginx ingress controller globalconfig from services  */}}
{{/* TESTED OK : 18/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################
  controller
*/}}
{{- define "sharedlibraries.helper_nginx_ingress_controller_globalconfig_spec_listeners" -}}
  {{/* include "sharedlibraries.dump" $ */}}
  {{- if and $.service $.service.customPorts }}
    {{- if or ( not $.globalconfig ) ( not $.globalconfig.spec ) ( not $.globalconfig.spec.listeners ) ( not $.globalconfig.disableHelper ) }}
      {{- $globalconfigSpecListeners := list }}
      {{- range $index, $currentCustomPorts := $.service.customPorts }}
        {{- if not $currentCustomPorts.protocol }}
          {{- $_ := set $currentCustomPorts "protocol" "TCP" }}
        {{- end }}
        {{/*  Keep add prefix HERE because it's handle from service.name  */}}
        {{- if not ( hasPrefix "ltn-" $currentCustomPorts.name ) }}
          {{- $_ := set $currentCustomPorts "name" ( printf "ltn-%s" $currentCustomPorts.name ) }}
        {{- end }}
        {{- $globalconfigSpecListeners = $currentCustomPorts  | append $globalconfigSpecListeners  }}
      {{- end }}
{{- $globalconfigSpecListeners | toYaml }}
    {{- else }}
      {{- $globalconfigSpecListeners := list }}
      {{- range $index, $currentListeners := $.globalconfig.spec.listeners }}
        {{- if not $currentListeners.protocol }}
          {{- $_ := set $currentListeners "protocol" "TCP" }}
        {{- end }}
        {{- if not ( hasPrefix "ltn-" $currentListeners.name ) }}
          {{- $_ := set $currentListeners "name" ( printf "ltn-%s" $currentListeners.name ) }}
        {{- end }}
        {{- $globalconfigSpecListeners = $currentListeners  | append $globalconfigSpecListeners  }}
      {{- end }}
{{- $globalconfigSpecListeners | toYaml }}
    {{- end }}
  {{- end }}
{{- end -}}
{{/* library template for nginx_ingress_controller definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################
nginx:
  controller:
  - name:
    namespace:
    # all other parameter accepted from
    #https://github.com/nginxinc/nginx-ingress-helm-operator/blob/v1.3.0/docs/nginx-ingress-controller.md
    # HELPER :
    #if you set service , listener will be created from service info
*/}}
{{- define "sharedlibraries.nginx_ingress_controller" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.nginx  */}}
  {{- if and (not $.Values.nginx) }}
    {{- fail "nginx_ingress_controller template loaded without nginx object" }}
  {{- end }}
  {{/* CHECK $.Values.nginx.controller  */}}
  {{- if and (not $.Values.nginx) }}
    {{- fail "nginx_ingress_controller template loaded without nginx.controller object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "globalConfiguration" "service" "pod" ) }}
  {{- range $controller := $.Values.nginx.controller }}
{{/* include "sharedlibraries.dump" $controller */}}
    {{/*
    ######################################
    Validation Mandatory Variables controller
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $controller.name
    ######################################
    */}}
    {{- if not $controller.name }}
      {{- fail "No name set inside nginx.controller object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $controller.namespace
    ######################################
    */}}
    {{- if not $controller.namespace }}
      {{- fail "No namespace set inside nginx.controller object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $controller.additionalLabels
    ######################################
    */}}
    {{- if and ( $controller.additionalLabels ) ( not (kindIs "map" $controller.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside nginx.controller object but type is :%s" (kindOf $controller.additionalLabels)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $controller.additionalAnnotations
    ######################################
    */}}
    {{- if and ($controller.additionalAnnotations) (not (kindIs "map" $controller.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside nginx.controller object but type is :%s" (kindOf $controller.additionalAnnotations)) }}
    {{- end }}
---
apiVersion: charts.nginx.org/v1alpha1
kind: NginxIngress
metadata:
  name: {{ $controller.name }}
  namespace: {{ $controller.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $controller.additionalLabels }}
{{ toYaml $controller.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $controller.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $controller.additionalAnnotations }}
{{ toYaml $controller.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  controller:
    {{- $parameterController := dict }}
    {{- $_ := set $parameterController "fromDict" $controller }}
    {{- $_ := set $parameterController "avoidList" $avoidKeys }}
    {{- $controllerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterController ) }}
    {{- if $controllerAdditionnalInfos }}
{{ toYaml $controllerAdditionnalInfos | indent 4 }}
    {{- end }}
    pod:
    {{- if $controller.pod }}
      {{- $avoidKeysPod := ( list "annotations" ) }}
      {{- $parameterPod := dict }}
      {{- $_ := set $parameterPod "fromDict" $controller.pod }}
      {{- $_ := set $parameterPod "avoidList" $avoidKeysPod }}
      {{- $podAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterPod ) }}
      {{- if $podAdditionnalInfos }}
{{ toYaml $podAdditionnalInfos | indent 6 }}
      {{- end }}
    {{- end }}
      annotations:
        argocd.argoproj.io/managed: "true"
        argocd.argoproj.io/application-name: {{ $.Release.Name }}
      {{- if and $controller.pod }}
        {{- if $controller.pod.annotations }}
{{ toYaml $controller.pod.annotations | indent 8 }}
        {{- end }}
      {{- end }}
    service:
    {{- $avoidKeysService := ( list "customPorts" "create" "annotations" ) }}
    {{- $parameterService := dict }}
    {{- $_ := set $parameterService "fromDict" $controller.service }}
    {{- $_ := set $parameterService "avoidList" $avoidKeysService }}
    {{- $serviceAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterService ) }}
      create: {{ default true $controller.service.create }}
      annotations:
        argocd.argoproj.io/managed: "true"
        argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $controller.service.annotations }}
{{ toYaml $controller.service.annotations | indent 8 }}
    {{- end }}
    {{- if $serviceAdditionnalInfos }}
{{ toYaml $serviceAdditionnalInfos | indent 6 }}
    {{- end }}
      customPorts:
    {{- if $controller.service.customPorts }}
      {{- range $serviceCustomPorts := $controller.service.customPorts }}
        {{- if hasPrefix "svc-" $serviceCustomPorts.name }}
        - name: {{ $serviceCustomPorts.name }}
        {{- else }}
        - name: {{ printf "svc-%s" $serviceCustomPorts.name }}
        {{- end }}
        {{- $avoidKeysServiceCustomPorts := ( list "name" ) }}
        {{- $parameterServiceCustomPorts := dict }}
        {{- $_ := set $parameterServiceCustomPorts "fromDict" $serviceCustomPorts }}
        {{- $_ := set $parameterServiceCustomPorts "avoidList" $avoidKeysServiceCustomPorts }}
        {{- $serviceCustomPortsAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterServiceCustomPorts ) }}
        {{- if $serviceCustomPortsAdditionnalInfos }}
{{ toYaml $serviceCustomPortsAdditionnalInfos | indent 10 }}
        {{- end }}
      {{- end }}
    {{- end }}
    globalConfiguration:
      {{- if and $controller.globalConfiguration ( hasKey $controller.globalConfiguration "create" ) }}
      create: {{- $controller.globalConfiguration.create }}
      {{- else }}
      create: true
      {{- end }}
    {{- $globalConfigSpecListeners := include "sharedlibraries.helper_nginx_ingress_controller_globalconfig_spec_listeners" $controller }}
    {{- if and ( $controller.globalConfiguration ) ( $controller.globalConfiguration.spec ) }}
      {{- $avoidKeysGlobalConfigurationSpec := ( list "listeners" ) }}
      {{- $parameterGlobalConfigurationSpec := dict }}
      {{- $_ := set $parameterGlobalConfigurationSpec "fromDict" $controller.globalConfiguration.spec }}
      {{- $_ := set $parameterGlobalConfigurationSpec "avoidList" $avoidKeysGlobalConfigurationSpec }}
      {{- $globalConfigurationSpecAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterGlobalConfigurationSpec ) }}
      spec:
      {{- if $globalConfigurationSpecAdditionnalInfos }}
{{ toYaml $globalConfigurationSpecAdditionnalInfos | indent 8 }}
      {{- end }}
      {{- if $globalConfigSpecListeners }}
        listeners:
{{ $globalConfigSpecListeners | indent 10 }}
      {{- end }}
    {{- else }}
      {{- if $globalConfigSpecListeners }}
      spec:
        listeners:
{{ $globalConfigSpecListeners | indent 10 }}
      {{- end }}
    {{- end }}
...
  {{/* END RANGE */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
