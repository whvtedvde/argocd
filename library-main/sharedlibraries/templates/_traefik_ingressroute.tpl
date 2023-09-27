{{- /* library template for traefik ingressroute definition */}}
{{- /* Parametre / Values
BEGVAL

# -- (dict) TRAEFIK definition
# @default -- see subconfig
# DOC: [traefik](https://doc.traefik.io/traefik/)
traefik:
  # -- (dict) TRAEFIK ingressRoute
  # @default -- see subconfig
  # DOC : [traefik](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/)
  ## HELPER TRAEFIK ingressroute AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, entryPoints, routes
  ingressRoute:
    -
      # -- (string)[REQ] name
      name: traefik-ingressroute-test
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
          # DOC : [service](https://doc.traefik.io/traefik/routing/services/#configuring-http-services)
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

              # -- (string)[OPT] passHostHeader
              passHostHeader: true
              # -- (int)[OPT] port
              port: 80
              # -- (dict)[OPT] responseForwarding
              responseForwarding:
                # -- (string)[OPT] flushInterval
                flushInterval: 1ms
              # -- (string)[OPT] scheme
              scheme: https
              # -- (string)[OPT] scheme
              serversTransport: traefik-transport-test
              # -- (dict)[OPT] sticky
              sticky:
                # -- (dict)[OPT] cookie
                cookie:
                  # -- (bool)[OPT] strategy
                  httpOnly: true
                  # -- (string)[OPT] strategy
                  name: cookie
                  # -- (bool)[OPT] secure
                  secure: true
                  # -- (string)[OPT] sameSite
                  sameSite: none
              # -- (string)[OPT] strategy
              strategy: RoundRobin
              # -- (int)[OPT] weight
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

      # -- (dict)[OPT] tls
      tls:

        # -- (string)[OPT] certResolver
        certResolver: oabresolver

        # domains
        # format : dict
        # [OPT]
        domains:

          # -- (string)[OPT] main
          ## Master name of certificate (will also be first SANS)
          main: example.net

          # -- (list)[OPT] sans
          ## list of all SANS to set inside certificate
          sans:
            - a.example.net
            - b.example.net

        # -- (dict)[OPT] options
        options:
          # -- (string)[OPT] name
          name: traefik-tlsoption-test
          # -- (string)[OPT] namespace
          namespace: outils

        # -- (string)[OPT] secretName
        secretName: supersecret

        # -- (dict)[OPT] store
        store:
          # -- (string)[OPT] name
          name: traefik-tlsstore-test
          # -- (string)[OPT] namespace
          namespace: outils

ENDVAL

*/}}
{{- define "sharedlibraries.traefik_ingressroute" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_ingressroute template loaded without traefik object" }}
  {{- end }}

  {{- if and ( not $.Values.traefik.ingressRoute ) }}
    {{- fail "traefik_ingressroute template loaded without traefik.ingressRoute object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "entryPoints" "routes" ) }}

  {{- /*
  #################################
  LOOP all ingressRoute instance
  #################################
  */}}
  {{- range $ingressRoute := $.Values.traefik.ingressRoute }}
    {{- /* DEBUG include "sharedlibraries.dump" $ingressRoute */}}


    {{- /* CHECK ingressRoute.name */}}
    {{- if not $ingressRoute.name }}
      {{- fail "No name set inside traefik.ingressRoute object" }}
    {{- end }}

    {{- /* CHECK ingressRoute.namespace */}}
    {{- if not $ingressRoute.namespace }}
      {{- fail "No namespace set inside traefik.ingressRoute object" }}
    {{- end }}

    {{- /* CHECK ingressRoute.additionalLabels */}}
    {{- if and ( $ingressRoute.additionalLabels ) ( not ( kindIs "map" $ingressRoute.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside traefik.ingressRoute object but type is :%s" ( kindOf $ingressRoute.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK ingressRoute.additionalAnnotations */}}
    {{- if and ( $ingressRoute.additionalAnnotations ) ( not ( kindIs "map" $ingressRoute.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside traefik.ingressRoute object but type is :%s" ( kindOf $ingressRoute.additionalAnnotations  ) ) }}
    {{- end }}

    {{- /* CHECK ingressRoute.name */}}
    {{- if not $ingressRoute.entryPoints }}
      {{- fail "No entryPoints set inside traefik.ingressRoute object" }}
    {{- end }}
    {{- if not ( kindIs "slice" $ingressRoute.entryPoints ) }}
      {{- fail ( printf "entryPoints is not a LIST inside traefik.ingressRoute object but type is :%s" ( kindOf $ingressRoute.entryPoints  ) ) }}
    {{- end }}

    {{- /* CHECK  parameterCheckDictRoutes */}}
    {{- $parameterCheckDictRoutes := dict }}
    {{- $parameterCheckDictRoutesMandatoryKeys := ( list "kind" "match" "services" ) }}
    {{- $_ := set $parameterCheckDictRoutes "fromDict" $ingressRoute }}
    {{- $_ := set $parameterCheckDictRoutes "masterKey" "routes" }}
    {{- $_ := set $parameterCheckDictRoutes "baseKey" "traefik.ingressRoute" }}
    {{- $_ := set $parameterCheckDictRoutes "mandatoryKeys" $parameterCheckDictRoutesMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRoutes }}

    {{- range $currentRoutes := $ingressRoute.routes }}

    {{- /* CHECK parameterCheckDictRoutesServices */}}
      {{- $parameterCheckDictRoutesServices := dict }}
      {{- $parameterCheckDictRoutesServicesMandatoryKeys := ( list "kind" "name" ) }}
      {{- $_ := set $parameterCheckDictRoutesServices "fromDict" $currentRoutes }}
      {{- $_ := set $parameterCheckDictRoutesServices "masterKey" "services" }}
      {{- $_ := set $parameterCheckDictRoutesServices "mandatoryKeys" $parameterCheckDictRoutesServicesMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRoutesServices }}
    {{- /* END RANGE currentRoutes */}}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: {{ $ingressRoute.name }}
  namespace: {{ $ingressRoute.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $ingressRoute.additionalLabels }}
{{ toYaml $ingressRoute.additionalLabels | indent 4 }}
    {{- /* END IF ingressRoute.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $ingressRoute.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $ingressRoute.additionalAnnotations }}
{{ toYaml $ingressRoute.additionalAnnotations | indent 4 }}
    {{- /* END IF ingressRoute.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameterIngressRoutes := dict }}
    {{- $_ := set $parameterIngressRoutes "fromDict" $ingressRoute }}
    {{- $_ := set $parameterIngressRoutes "avoidList" $avoidKeys }}
    {{- $ingressRouteAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterIngressRoutes ) }}
    {{- if $ingressRouteAdditionnalInfos }}
{{ toYaml $ingressRouteAdditionnalInfos | indent 2 }}
    {{- /* END IF ingressRouteAdditionnalInfos */}}
    {{- end }}
  entryPoints:
{{ toYaml $ingressRoute.entryPoints | indent 4 }}
  routes:
    {{- range $currentRoutes := $ingressRoute.routes }}
    - kind: {{ $currentRoutes.kind }}
      match: {{ $currentRoutes.match }}
      {{- range $currentRoutesServices := $currentRoutes.services }}
      services:
        - kind: {{ $currentRoutesServices.kind }}
          name: {{ $currentRoutesServices.name }}
        {{- $parameterIngressRoutesServices := dict }}
        {{- $avoidKeyscurrentRoutesServices := ( list "kind" "name" ) }}
        {{- $_ := set $parameterIngressRoutesServices "fromDict" $currentRoutesServices }}
        {{- $_ := set $parameterIngressRoutesServices "avoidList" $avoidKeyscurrentRoutesServices }}
        {{- $ingressRoutesServicesAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterIngressRoutesServices ) }}
        {{- if $ingressRoutesServicesAdditionnalInfos }}
{{ toYaml $ingressRoutesServicesAdditionnalInfos | indent 10 }}
        {{- /* END IF ingressRoutesServicesAdditionnalInfos */}}
        {{- end }}
      {{- /* END RANGE currentRoutesServices */}}
      {{- end }}
      {{- $parameterIngressRoutesCurrentRoutes := dict }}
      {{- $avoidKeyscurrentRoutesCurrentRoutes := ( list "kind" "match" "services" ) }}
      {{- $_ := set $parameterIngressRoutesCurrentRoutes "fromDict" $currentRoutes }}
      {{- $_ := set $parameterIngressRoutesCurrentRoutes "avoidList" $avoidKeyscurrentRoutesCurrentRoutes }}
      {{- $ingressRoutesCurrentRoutesAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterIngressRoutesCurrentRoutes ) }}
      {{- if $ingressRoutesCurrentRoutesAdditionnalInfos }}
{{ toYaml $ingressRoutesCurrentRoutesAdditionnalInfos | indent 6 }}
      {{- /* END IF ingressRoutesCurrentRoutesAdditionnalInfos */}}
      {{- end }}
    {{- /* END RANGE currentRoutes */}}
    {{- end }}
...
  {{- /* END RANGE ingressRoute */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
