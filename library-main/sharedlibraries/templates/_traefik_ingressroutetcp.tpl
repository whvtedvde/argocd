{{- /* library template for traefik ingressroutetcp definition */}}
{{- /*
BEGVAL
# -- (dict) TRAEFIK definition
# @default -- see subconfig
# DOC: [traefik](https://doc.traefik.io/traefik/)
traefik:
 # -- Create TRAEFIK ingressroutetcp
  # @default -- see subconfig
  # DOC : [traefik ingressroutetcp](https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-ingressroutetcp)
  ## HELPER TRAEFIK ingressroute AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, entryPoints, routes
  ingressRouteTCP:
    -
      # -- (string)[REQ] name
      name: traefik-ingressroutetcp-test
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
          # -- (string)[OPT] match
          match: HostSNI(`*`)

          # -- (list)[REQ] services
          # DOC : [traefik service](https://doc.traefik.io/traefik/routing/services/#configuring-http-services)
          ## HELPER TRAEFIK routes.services AdditionnalInfos
          ## write as YAML (without formating or validation) everything except:
          ## kind,name,namespace
          services:
            -
              # -- (string)[REQ] name
              name: svc-test
              # -- (string)[REQ] namespace
              namespace: outils


              # -- (int)[OPT] port
              port: 8080
              # -- (int)[OPT] weight
              weight: 10
              # -- (int)[OPT] terminationDelay
              terminationDelay: 400
              # -- (dict)[OPT] proxyProtocol
              proxyProtocol:
                # -- (int)[OPT] version
                version: 1
              # -- (bool)[OPT] port
              nativeLB: true

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

        # -- (bool)[OPT] passthrough
        passthrough: false

ENDVAL
*/}}
{{- define "sharedlibraries.traefik_ingressroutetcp" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_ingressroutetcp template loaded without traefik object" }}
  {{- end }}

  {{- if and (not $.Values.traefik.ingressRouteTCP ) }}
    {{- fail "traefik_ingressroutetcp template loaded without traefik.ingressRouteTCP object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "entryPoints" "routes" ) }}

  {{- /*
  #################################
  LOOP all installplan instance
  #################################
  */}}
  {{- range $ingressRouteTCP := $.Values.traefik.ingressRouteTCP }}
    {{- /* DEBUG include "sharedlibraries.dump" $ingressRouteTCP */}}

    {{- /*
    #################################
    CHECK mandatory ingressRouteTCP values
    #################################
    */}}

    {{- /* CHECK ingressRouteTCP.name */}}
    {{- if not $ingressRouteTCP.name }}
      {{- fail "No name set inside traefik.ingressRouteTCP object" }}
    {{- end }}

    {{- /* CHECK ingressRouteTCP.namespace */}}
    {{- if not $ingressRouteTCP.namespace }}
      {{- fail "No namespace set inside traefik.ingressRouteTCP object" }}
    {{- end }}

    {{- /* CHECK ingressRouteTCP.additionalLabels */}}
    {{- if and ( $ingressRouteTCP.additionalLabels ) ( not ( kindIs "map" $ingressRouteTCP.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside traefik.ingressRouteTCP object but type is :%s" ( kindOf $ingressRouteTCP.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK ingressRouteTCP.additionalAnnotations */}}
    {{- if and ( $ingressRouteTCP.additionalAnnotations ) ( not ( kindIs "map" $ingressRouteTCP.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside traefik.ingressRouteTCP object but type is :%s" ( kindOf $ingressRouteTCP.additionalAnnotations  ) ) }}
    {{- end }}

    {{- /* CHECK ingressRouteTCP.entryPoints */}}
    {{- if not $ingressRouteTCP.entryPoints }}
      {{- fail "No entryPoints set inside traefik.ingressRouteTCP object" }}
    {{- end }}
    {{- if not ( kindIs "slice" $ingressRouteTCP.entryPoints ) }}
      {{- fail ( printf "entryPoints is not a LIST inside traefik.ingressRouteTCP object but type is :%s" ( kindOf $ingressRouteTCP.entryPoints  ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictRoutes */}}
    {{- $parameterCheckDictRoutes := dict }}
    {{- $parameterCheckDictRoutesMandatoryKeys := ( list "match" "services" ) }}
    {{- $_ := set $parameterCheckDictRoutes "fromDict" $ingressRouteTCP }}
    {{- $_ := set $parameterCheckDictRoutes "masterKey" "routes" }}
    {{- $_ := set $parameterCheckDictRoutes "baseKey" "traefik.ingressRouteTCP" }}
    {{- $_ := set $parameterCheckDictRoutes "mandatoryKeys" $parameterCheckDictRoutesMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRoutes }}
    {{- range $currentRoutes := $ingressRouteTCP.routes }}

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
kind: IngressRouteTCP
metadata:
  name: {{ $ingressRouteTCP.name }}
  namespace: {{ $ingressRouteTCP.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $ingressRouteTCP.additionalLabels }}
{{ toYaml $ingressRouteTCP.additionalLabels | indent 4 }}
    {{- /* END IF ingressroutetcp.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $ingressRouteTCP.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $ingressRouteTCP.additionalAnnotations }}
{{ toYaml $ingressRouteTCP.additionalAnnotations | indent 4 }}
    {{- /* END IF ingressroutetcp.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameteringressroutetcps := dict }}
    {{- $_ := set $parameteringressroutetcps "fromDict" $ingressRouteTCP }}
    {{- $_ := set $parameteringressroutetcps "avoidList" $avoidKeys }}
    {{- $ingressRouteTCPAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameteringressroutetcps ) }}
    {{- if $ingressRouteTCPAdditionnalInfos }}
{{ toYaml $ingressRouteTCPAdditionnalInfos | indent 2 }}
    {{- /* END IF ingressroutetcpAdditionnalInfos */}}
    {{- end }}
  entryPoints:
{{ toYaml $ingressRouteTCP.entryPoints | indent 4 }}
  routes:
    {{- range $currentRoutes := $ingressRouteTCP.routes }}
    - match: {{ $currentRoutes.match }}
      {{- range $currentRoutesServices := $currentRoutes.services }}
      services:
        - name: {{ $currentRoutesServices.name }}
        {{- $parameteringressroutetcpsServices := dict }}
        {{- $avoidKeyscurrentRoutesServices := ( list "kind" "name" ) }}
        {{- $_ := set $parameteringressroutetcpsServices "fromDict" $currentRoutesServices }}
        {{- $_ := set $parameteringressroutetcpsServices "avoidList" $avoidKeyscurrentRoutesServices }}
        {{- $ingressRouteTCPsServicesAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameteringressroutetcpsServices ) }}
        {{- if $ingressRouteTCPsServicesAdditionnalInfos }}
{{ toYaml $ingressRouteTCPsServicesAdditionnalInfos | indent 10 }}
        {{- /* END IF ingressroutetcpsServicesAdditionnalInfos */}}
        {{- end }}
      {{- /* END RANGE currentRoutesServices */}}
      {{- end }}
      {{- $parameteringressroutetcpsCurrentRoutes := dict }}
      {{- $avoidKeyscurrentRoutesCurrentRoutes := ( list "kind" "match" "services" ) }}
      {{- $_ := set $parameteringressroutetcpsCurrentRoutes "fromDict" $currentRoutes }}
      {{- $_ := set $parameteringressroutetcpsCurrentRoutes "avoidList" $avoidKeyscurrentRoutesCurrentRoutes }}
      {{- $ingressRouteTCPsCurrentRoutesAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameteringressroutetcpsCurrentRoutes ) }}
      {{- if $ingressRouteTCPsCurrentRoutesAdditionnalInfos }}
{{ toYaml $ingressRouteTCPsCurrentRoutesAdditionnalInfos | indent 6 }}
      {{- /* END IF ingressroutetcpsCurrentRoutesAdditionnalInfos */}}
      {{- end }}
    {{- /* END RANGE currentRoutes */}}
    {{- end }}
...
  {{- /* END RANGE ingressroutetcp */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
