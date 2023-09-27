{{/* library template for nginx transport server definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################
nginx:
  # -- Create NGINX transport-server
  # DOC : https://docs.nginx.com/nginx-ingress-controller/configuration/transportserver-resource/
  # [REQ]
  transport-server:
      # NGINX transport-server name
      # [REQ]
    - name: nginx-ingress
      # NGINX transport-server namespace
      # [REQ]
      namespace: nginxingress
      # Etape ArgoCD
      # DEF : 04
      # [OPT]
      syncWave: 04

      # ingressClassName
      # [REQ]
      ingressClassName:

      # listener
      # format : map / dict
      # [REQ]
      listener:
        # listener name
        # [REQ]
        name: ltn-test
        # listener protocol
        # [REQ]
        protocol: TCP

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

      # action
      # format : map / dict
      # [REQ]
      action:
        # action name
        # [REQ]
        pass: upstream-test


      # HELPER transport-server AdditionnalInfos
      # write as YAML (without formating or validation) everything except:
      # name
      # namespace
      # additionalLabel
      # additionalAnnotations
      # ingressClassName
      # listener
      # upstreams
      # action
*/}}
{{- define "sharedlibraries.nginx_transport_server" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.nginx  */}}
  {{- if and (not $.Values.nginx) }}
    {{- fail "nginx_transport_server template loaded without nginx object" }}
  {{- end }}
  {{/* CHECK $.Values.nginx.transportServer  */}}
  {{- if and (not $.Values.nginx) }}
    {{- fail "nginx_transport_server template loaded without nginx.transportServer object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "ingressClassName" "listener" "upstreams" "action" ) }}
  {{- range $transportServer := $.Values.nginx.transportServer }}
    {{/* DEBUG include "sharedlibraries.dump" $transportServer */}}
    {{/*
    ######################################
    Validation Mandatory Variables transportServer
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $transportServer.name
    ######################################
    */}}
    {{- if not $transportServer.name }}
      {{- fail "No name set inside nginx.transportServer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $transportServer.namespace
    ######################################
    */}}
    {{- if not $transportServer.namespace }}
      {{- fail "No namespace set inside nginx.transportServer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $transportServer.additionalLabels
    ######################################
    */}}
    {{- if and ( $transportServer.additionalLabels ) ( not (kindIs "map" $transportServer.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside nginx.transportServer object but type is :%s" (kindOf $transportServer.additionalLabels)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $transportServer.additionalAnnotations
    ######################################
    */}}
    {{- if and ($transportServer.additionalAnnotations) (not (kindIs "map" $transportServer.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside nginx.transportServer object but type is :%s" (kindOf $transportServer.additionalAnnotations)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK $transportServer.ingressClassName
    ######################################
    */}}
    {{- if not $transportServer.ingressClassName }}
      {{- fail "No ingressClassName set inside nginx.transportServer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $transportServer.listener
    ######################################
    */}}
    {{- $parameterCheckDictListener := dict }}
    {{- $parameterCheckDictListenerMandatoryKeys := ( list "name" "protocol" ) }}
    {{- $_ := set $parameterCheckDictListener "fromDict" $transportServer }}
    {{- $_ := set $parameterCheckDictListener "masterKey" "listener" }}
    {{- $_ := set $parameterCheckDictListener "baseKey" "nginx.transportServer" }}
    {{- $_ := set $parameterCheckDictListener "mandatoryKeys" $parameterCheckDictListenerMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictListener }}
    {{/*
    ######################################
    CHECK $transportServer.upstreams
    ######################################
    */}}
    {{- $parameterCheckDictUpstreams := dict }}
    {{- $parameterCheckDictUpstreamsMandatoryKeys := ( list "name" "port" "service" ) }}
    {{- $_ := set $parameterCheckDictUpstreams "fromDict" $transportServer }}
    {{- $_ := set $parameterCheckDictUpstreams "masterKey" "upstreams" }}
    {{- $_ := set $parameterCheckDictUpstreams "baseKey" "nginx.transportServer" }}
    {{- $_ := set $parameterCheckDictUpstreams "mandatoryKeys" $parameterCheckDictUpstreamsMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDictUpstreams }}
    {{/*
    ######################################
    CHECK $transportServer.action
    ######################################
    */}}
    {{- $parameterCheckDictAction := dict }}
    {{- $parameterCheckDictActionMandatoryKeys := ( list "pass" ) }}
    {{- $_ := set $parameterCheckDictAction "fromDict" $transportServer }}
    {{- $_ := set $parameterCheckDictAction "masterKey" "action" }}
    {{- $_ := set $parameterCheckDictAction "baseKey" "nginx.transportServer" }}
    {{- $_ := set $parameterCheckDictAction "mandatoryKeys" $parameterCheckDictActionMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictAction }}
---
apiVersion: k8s.nginx.org/v1alpha1
kind: TransportServer
metadata:
  name: {{ $transportServer.name }}
  namespace: {{ $transportServer.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $transportServer.additionalLabels }}
{{ toYaml $transportServer.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $transportServer.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $transportServer.additionalAnnotations }}
{{ toYaml $transportServer.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
    {{- $parameterTransportServer := dict }}
    {{- $_ := set $parameterTransportServer "fromDict" $transportServer }}
    {{- $_ := set $parameterTransportServer "avoidList" $avoidKeys }}
    {{- $transportServerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterTransportServer ) }}
    {{- if $transportServerAdditionnalInfos }}
{{ toYaml $transportServerAdditionnalInfos | indent 6 }}
    {{- end }}
  ingressClassName: {{ $transportServer.ingressClassName }}
  listener:
    {{- if hasPrefix "ltn-" $transportServer.listener.name }}
    name: {{ $transportServer.action.name }}
    {{- else }}
    name: {{ printf "ltn-%s" $transportServer.listener.name }}
    {{- end }}
    protocol: {{ $transportServer.listener.protocol }}
  upstreams:
    {{- range $currentUpstreams := $transportServer.upstreams }}
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
  action:
    {{- if hasPrefix "upstream-" $transportServer.action.pass }}
    pass: {{ $transportServer.action.pass }}
    {{- else }}
    pass: {{ printf "upstream-%s" $transportServer.action.pass }}
    {{- end }}
...
  {{/* END RANGE */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
