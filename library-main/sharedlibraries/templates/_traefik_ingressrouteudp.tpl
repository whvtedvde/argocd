{{- /* library template for traefik ingressrouteudp definition */}}
{{- /*
BEGVAL

# -- (dict) TRAEFIK definition
# @default -- see subconfig
# DOC: [traefik](https://doc.traefik.io/traefik/)
traefik:
traefik:
  # -- Create TRAEFIK ingressrouteudp
  # @default -- see subconfig
  # DOC : [traefik ingressrouteudp](https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-ingressrouteudp)
  ## HELPER TRAEFIK ingressroutetcp AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, entryPoints, routes
  ingressRouteUDP:
    -
      # -- (string)[REQ] name
      name: traefik-ingressrouteudp-test
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


      # -- (list)[OPT] entryPoints
      ## DEF : all
      entryPoints:
        - web
        - websecure

      # -- (list)[REQ] routes
      ## HELPER TRAEFIK routes AdditionnalInfos
      ## write as YAML (without formating or validation) everything except:
      ## kind,match,services
      routes:
        -
          # -- (list)[REQ] kind
          kind: rule

          # -- (string)[OPT] match
          match: HostSNI(`*`)

          # -- (list)[REQ] services
          # DOC : [traefik service](https://doc.traefik.io/traefik/routing/services/#configuring-http-services)
          ## HELPER TRAEFIK routes.services AdditionnalInfos
          ## write as YAML (without formating or validation) everything except:
          ## kind,name,namespace
          services:
            -
              # -- (string)[REQ] kind
              kind: Service
              # -- (string)[REQ] name
              name: svc-test
              # -- (string)[REQ] namespace
              namespace: outils

              # -- (int)[REQ] port
              port: 8080
              # -- (int)[REQ] weight
              weight: 10

          # -- (list)[OPT] services
          middlewares:
            -
              # -- (string)[OPT] name
              name: traefik-middleware-test
              # -- (string)[OPT] namespace
              namespace: outils

          # -- (string)[OPT] passHostHeader
          ## DEF = 0 (disable)
          priority: 0

ENDVAL
*/}}
{{- define "sharedlibraries.traefik_ingressrouteudp" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_ingressrouteudp template loaded without traefik object" }}
  {{- end }}

  {{- if and (not $.Values.traefik.ingressRouteUDP ) }}
    {{- fail "traefik_ingressrouteudp template loaded without traefik.ingressRouteUDP object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "entryPoints" "routes" ) }}

  {{- /*
  #################################
  LOOP all ingressRouteUDP instance
  #################################
  */}}
  {{- range $ingressRouteUDP := $.Values.traefik.ingressRouteUDP }}
    {{- /* DEBUG include "sharedlibraries.dump" $ingressRouteUDP */}}
    {{- /*
    #################################
    CHECK mandatory ingressRouteUDP values
    #################################
    */}}
    {{- /* CHECK ingressRouteUDP.name */}}
    {{- if not $ingressRouteUDP.name }}
      {{- fail "No name set inside traefik.ingressRouteUDP object" }}
    {{- end }}

    {{- /* CHECK ingressRouteUDP.namespace */}}
    {{- if not $ingressRouteUDP.namespace }}
      {{- fail "No namespace set inside traefik.ingressRouteUDP object" }}
    {{- end }}

    {{- /* CHECK ingressRouteUDP.additionalLabels */}}
    {{- if and ( $ingressRouteUDP.additionalLabels ) ( not (kindIs "map" $ingressRouteUDP.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside traefik.ingressRouteUDP object but type is :%s" ( kindOf $ingressRouteUDP.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK ingressRouteUDP.additionalAnnotations */}}
    {{- if and ($ingressRouteUDP.additionalAnnotations) (not (kindIs "map" $ingressRouteUDP.additionalAnnotations ) ) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside traefik.ingressRouteUDP object but type is :%s" ( kindOf $ingressRouteUDP.additionalAnnotations  ) ) }}
    {{- end }}

    {{- /* CHECK ingressRouteUDP.entryPoints */}}
    {{- if not $ingressRouteUDP.entryPoints }}
      {{- fail "No entryPoints set inside traefik.ingressRouteUDP object" }}
    {{- end }}
    {{- if not (kindIs "slice" $ingressRouteUDP.entryPoints ) }}
      {{- fail (printf "entryPoints is not a LIST inside traefik.ingressRouteUDP object but type is :%s" ( kindOf $ingressRouteUDP.entryPoints  ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictRoutes */}}
    {{- $parameterCheckDictRoutes := dict }}
    {{- $parameterCheckDictRoutesMandatoryKeys := ( list "services" ) }}
    {{- $_ := set $parameterCheckDictRoutes "fromDict" $ingressRouteUDP }}
    {{- $_ := set $parameterCheckDictRoutes "masterKey" "routes" }}
    {{- $_ := set $parameterCheckDictRoutes "baseKey" "traefik.ingressRouteUDP" }}
    {{- $_ := set $parameterCheckDictRoutes "mandatoryKeys" $parameterCheckDictRoutesMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRoutes }}
    {{- range $currentRoutes := $ingressRouteUDP.routes }}

      {{- /* CHECK parameterCheckDictRoutesServices */}}
      {{- $parameterCheckDictRoutesServices := dict }}
      {{- $parameterCheckDictRoutesServicesMandatoryKeys := ( list "name" ) }}
      {{- $_ := set $parameterCheckDictRoutesServices "fromDict" $currentRoutes }}
      {{- $_ := set $parameterCheckDictRoutesServices "masterKey" "services" }}
      {{- $_ := set $parameterCheckDictRoutesServices "mandatoryKeys" $parameterCheckDictRoutesServicesMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRoutesServices }}
    {{- /* END RANGE currentRoutes */}}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: traefik.io/v1alpha1
kind: IngressRouteUDP
metadata:
  name: {{ $ingressRouteUDP.name }}
  namespace: {{ $ingressRouteUDP.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $ingressRouteUDP.additionalLabels }}
{{ toYaml $ingressRouteUDP.additionalLabels | indent 4 }}
    {{- /* END IF ingressrouteudp.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $ingressRouteUDP.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $ingressRouteUDP.additionalAnnotations }}
{{ toYaml $ingressRouteUDP.additionalAnnotations | indent 4 }}
    {{- /* END IF ingressrouteudp.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameteringressrouteudp := dict }}
    {{- $_ := set $parameteringressrouteudp "fromDict" $ingressRouteUDP }}
    {{- $_ := set $parameteringressrouteudp "avoidList" $avoidKeys }}
    {{- $ingressRouteUDPAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameteringressrouteudp ) }}
    {{- if $ingressRouteUDPAdditionnalInfos }}
{{ toYaml $ingressRouteUDPAdditionnalInfos | indent 2 }}
    {{- /* END IF ingressrouteudpAdditionnalInfos */}}
    {{- end }}
  entryPoints:
{{ toYaml $ingressRouteUDP.entryPoints | indent 4 }}
  routes:
    {{- range $currentRoutes := $ingressRouteUDP.routes }}
      {{- range $currentRoutesServices := $currentRoutes.services }}
    - services:
        - name: {{ $currentRoutesServices.name }}
        {{- $parameteringressrouteudpServices := dict }}
        {{- $avoidKeyscurrentRoutesServices := ( list "name" ) }}
        {{- $_ := set $parameteringressrouteudpServices "fromDict" $currentRoutesServices }}
        {{- $_ := set $parameteringressrouteudpServices "avoidList" $avoidKeyscurrentRoutesServices }}
        {{- $ingressRouteUDPServicesAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameteringressrouteudpServices ) }}
        {{- if $ingressRouteUDPServicesAdditionnalInfos }}
{{ toYaml $ingressRouteUDPServicesAdditionnalInfos | indent 10 }}
        {{- /* END IF ingressrouteudpServicesAdditionnalInfos */}}
        {{- end }}
      {{- /* END RANGE currentRoutesServices */}}
      {{- end }}
      {{- $parameteringressrouteudpCurrentRoutes := dict }}
      {{- $avoidKeyscurrentRoutesCurrentRoutes := ( list "services" ) }}
      {{- $_ := set $parameteringressrouteudpCurrentRoutes "fromDict" $currentRoutes }}
      {{- $_ := set $parameteringressrouteudpCurrentRoutes "avoidList" $avoidKeyscurrentRoutesCurrentRoutes }}
      {{- $ingressRouteUDPCurrentRoutesAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameteringressrouteudpCurrentRoutes ) }}
      {{- if $ingressRouteUDPCurrentRoutesAdditionnalInfos }}
{{ toYaml $ingressRouteUDPCurrentRoutesAdditionnalInfos | indent 6 }}
      {{- /* END IF ingressrouteudpCurrentRoutesAdditionnalInfos */}}
      {{- end }}
    {{- /* END RANGE currentRoutes */}}
    {{- end }}
...
  {{- /* END RANGE ingressrouteudp */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
