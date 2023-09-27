{{/* library template for nginx virtual server definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################
nginx:
  # -- Create NGINX virtual-server
  # DOC : https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/
  # [REQ]
  virtual-server:
      # NGINX virtual-server name
      # [REQ]
    - name: vs-nginxingress
      # NGINX virtual-server namespace
      # [REQ]
      namespace: nginxingress
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # host
      # [REQ]
      host:

      # ingressClassName
      # [REQ]
      ingressClassName:

      # routes
      # format : list
      # [REQ]
      routes:
          # routes path
          # [REQ]
        - path: /test

          # routes action
          # [REQ]
          action:
            pass: upstream-test

            # HELPER routes action AdditionnalInfos
            # write as YAML (without formating or validation) everything except:
            # pass

          # HELPER routes AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # path
          # action
          # service

      # upstreams
      # format : list
      # [REQ]
      upstreams:
          # upstreams name
          # [REQ]
        - name: upstream-test
          # upstreams port
          # [REQ]
          port: 3000
          # upstreams service
          # [REQ]
          service: svc-test

          # HELPER upstreams AdditionnalInfos
          # write as YAML (without formating or validation) everything except:
          # name
          # port
          # service

      # HELPER virtual-server AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # host
      # ingressClassName
      # routes
      # upstreams
*/}}
{{- define "sharedlibraries.nginx_virtual_server" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.nginx  */}}
  {{- if and (not $.Values.nginx) }}
    {{- fail "nginx_transport_server template loaded without nginx object" }}
  {{- end }}
  {{/* CHECK $.Values.nginx.virtualServer  */}}
  {{- if and (not $.Values.nginx) }}
    {{- fail "nginx_transport_server template loaded without nginx.virtualServer object" }}
  {{- end }}
  {{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "host" "ingressClassName" "routes" "upstreams" ) }}
  {{- range $virtualServer := $.Values.nginx.virtualServer }}
    {{/* include "sharedlibraries.dump" $virtualServer */}}
    {{/*
    ######################################
    Validation Mandatory Variables virtualServer
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $virtualServer.name
    ######################################
    */}}
    {{- if not $virtualServer.name }}
      {{- fail "No name set inside nginx.virtualServer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $virtualServer.namespace
    ######################################
    */}}
    {{- if not $virtualServer.namespace }}
      {{- fail "No namespace set inside nginx.virtualServer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $virtualServer.additionalLabels
    ######################################
    */}}
    {{- if and ( $virtualServer.additionalLabels ) ( not (kindIs "map" $virtualServer.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside nginx.virtualServer object but type is :%s" (kindOf $virtualServer.additionalLabels)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $virtualServer.additionalAnnotations
    ######################################
    */}}
    {{- if and ($virtualServer.additionalAnnotations) (not (kindIs "map" $virtualServer.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside nginx.virtualServer object but type is :%s" (kindOf $virtualServer.additionalAnnotations)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK $virtualServer.host
    ######################################
    */}}
    {{- if not $virtualServer.host }}
      {{- fail "No host set inside nginx.virtualServer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $virtualServer.ingressClassName
    ######################################
    */}}
    {{- if not $virtualServer.ingressClassName }}
      {{- fail "No ingressClassName set inside nginx.virtualServer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $virtualServer.routes
    ######################################
    */}}
    {{- $parameterCheckDictRoutes := dict }}
    {{- $parameterCheckDictRoutesMandatoryKeys := ( list "path" "action" ) }}
    {{- $_ := set $parameterCheckDictRoutes "fromDict" $virtualServer }}
    {{- $_ := set $parameterCheckDictRoutes "masterKey" "routes" }}
    {{- $_ := set $parameterCheckDictRoutes "baseKey" "nginx.virtualServer" }}
    {{- $_ := set $parameterCheckDictRoutes "mandatoryKeys" $parameterCheckDictRoutesMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRoutes }}
    {{/*
    ######################################
    CHECK $virtualServer.upstreams
    ######################################
    */}}
    {{- $parameterCheckDictUpstreams := dict }}
    {{- $parameterCheckDictUpstreamsMandatoryKeys := ( list "name" "port" "service" ) }}
    {{- $_ := set $parameterCheckDictUpstreams "fromDict" $virtualServer }}
    {{- $_ := set $parameterCheckDictUpstreams "masterKey" "upstreams" }}
    {{- $_ := set $parameterCheckDictUpstreams "baseKey" "nginx.virtualServer" }}
    {{- $_ := set $parameterCheckDictUpstreams "mandatoryKeys" $parameterCheckDictUpstreamsMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDictUpstreams }}
---
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: {{ $virtualServer.name }}
  namespace: {{ $virtualServer.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $virtualServer.additionalLabels }}
{{ toYaml $virtualServer.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $virtualServer.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $virtualServer.additionalAnnotations }}
{{ toYaml $virtualServer.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
    {{- $parametervirtualServer := dict }}
    {{- $_ := set $parametervirtualServer "fromDict" $virtualServer }}
    {{- $_ := set $parametervirtualServer "avoidList" $avoidKeys }}
    {{- $virtualServerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametervirtualServer ) }}
    {{- if $virtualServerAdditionnalInfos }}
{{ toYaml $virtualServerAdditionnalInfos | indent 2 }}
    {{- end }}
  host: {{ $virtualServer.host }}
  ingressClassName: {{ $virtualServer.ingressClassName }}
  upstreams:
    {{- range $currentUpstreams := $virtualServer.upstreams }}
      {{- if hasPrefix "upstream-" $currentUpstreams.name }}
    - name: {{ $currentUpstreams.name }}
      {{- else }}
    - name: {{ printf "upstream-%s" $currentUpstreams.name }}
      {{- end }}
      {{- if hasPrefix "svc-" $currentUpstreams.service }}
      service: {{ $currentUpstreams.service }}
      {{- else }}
      service: {{ printf "svc-%s" $currentUpstreams.service }}
      {{- end }}
      port: {{ $currentUpstreams.port }}
      {{- $avoidKeysCurrentUpstream := ( list "name" "service" "port" ) }}
      {{- $parameterCurrentUpstream := dict }}
      {{- $_ := set $parameterCurrentUpstream "fromDict" $currentUpstreams }}
      {{- $_ := set $parameterCurrentUpstream "avoidList" $avoidKeysCurrentUpstream }}
      {{- $currentUpstreamAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterCurrentUpstream ) }}
      {{- if $currentUpstreamAdditionnalInfos }}
{{ toYaml $currentUpstreamAdditionnalInfos | indent 6 }}
      {{- end }}
    {{- end }}
  routes:
    {{- range $currentRoute := $virtualServer.routes }}
    - path: {{ $currentRoute.path }}
      {{- if $currentRoute.action }}
      action:
        {{- if and $currentRoute.action.pass ( kindIs "string" $currentRoute.action.pass ) }}
          {{- if hasPrefix "upstream-" $currentRoute.action.pass }}
        pass: {{ $currentRoute.action.pass }}
          {{- else }}
        pass: {{ printf "upstream-%s" $currentRoute.action.pass }}
          {{- end }}
        {{- end }}
        {{- $avoidKeysCurrentRouteAction := ( list "pass" ) }}
        {{- $parameterCurrentRouteAction := dict }}
        {{- $_ := set $parameterCurrentRouteAction "fromDict" $currentRoute.action }}
        {{- $_ := set $parameterCurrentRouteAction "avoidList" $avoidKeysCurrentRouteAction }}
        {{- $currentRouteActionAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterCurrentRouteAction ) }}
        {{- if $currentRouteActionAdditionnalInfos }}
{{ toYaml $currentRouteActionAdditionnalInfos | indent 8 }}
        {{- end }}
      {{- end }}
      {{- $avoidKeysCurrentRoute := ( list "path" "action") }}
      {{- $parameterCurrentRoute := dict }}
      {{- $_ := set $parameterCurrentRoute "fromDict" $currentRoute }}
      {{- $_ := set $parameterCurrentRoute "avoidList" $avoidKeysCurrentRoute }}
      {{- $currentRouteAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterCurrentRoute ) }}
      {{- if $currentRouteAdditionnalInfos }}
{{ toYaml $currentRouteAdditionnalInfos | indent 6 }}
      {{- end }}
    {{- end }}
...
  {{/* END RANGE */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
