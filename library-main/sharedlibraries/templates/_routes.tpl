{{- /* library template for routes definition */ -}}
{{- /*
BEGVAL
# -- (dict) routes
# @default -- see subconfig
# DOC: [routes](https://docs.openshift.com/online/pro/architecture/networking/routes.html)
# API: [routes](https://docs.openshift.com/container-platform/4.13/rest_api/network_apis/route-route-openshift-io-v1.html)
routes:
  # -- Create routes
  # @default -- see subconfig
  ## HELPER routes AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, to , port
  -
    # -- (string)[REQ] name
    name: route-test
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
    syncWave: 05

    # -- (dict)[REQ] exposed service
    # Has to be a valid service kind
    service: svc-test

    # -- (list)[REQ] port
    # Name or the number port
    port: http

  -
    # -- (string)[REQ] name
    name: route-myapp
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
    syncWave: 05

    # -- (dict)[REQ] exposed service
    # Has to be a valid service kind
    service: svc-niceapp

    # -- (list)[REQ] port
    port: 8080

ENDVAL
*/ -}}
{{- define "sharedlibraries.routes" -}}

  {{- /*  Validation GENERAL */ -}}

  {{- /* CHECK mandatory global values  */ -}}

  {{- if not $.Values.routes -}}
    {{- fail "routes template loaded without routes object" -}}
  {{- end -}}

  {{- /*  CREATE global avoid keys  */ -}}
  {{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "port" "service" ) -}}

  {{- /*  LOOP all routes instance  */ -}}
  {{- range $route := $.Values.routes -}}

    {{- /* CHECK mandatory route values */ -}}

    {{- /* CHECK route.name */ -}}
    {{- if not $route.name -}}
      {{- fail "no name set inside routes object" -}}
    {{- end -}}

    {{- /* CHECK route.namespace */ -}}
    {{- if not $route.namespace -}}
      {{- fail "no namespace set inside routes object" -}}
    {{- end -}}

    {{- /* CHECK route.additionalLabels */ -}}
    {{- if and ( $route.additionalLabels ) ( not ( kindIs "map" $route.additionalLabels ) ) -}}
      {{- fail ( printf "additionalLabels is not a DICT inside routes object but type is :%s" ( kindOf $route.additionalLabels ) ) -}}
    {{- end -}}

    {{- /* CHECK route.additionalAnnotations */ -}}
    {{- if and ( $route.additionalAnnotations ) ( not ( kindIs "map" $route.additionalAnnotations ) ) -}}
      {{- fail ( printf "additionalAnnotations is not a DICT inside routes object but type is :%s" ( kindOf $route.additionalAnnotations ) ) -}}
    {{- end -}}

    {{- /* CHECK route.service */ -}}
    {{- if not $route.service -}}
      {{- fail "No service target \"service\" set inside routes object" -}}
    {{- end -}}

    {{- /* CHECK route.port */ -}}
    {{- if not $route.port -}}
      {{- fail "No port set inside routes object" -}}
    {{- end -}}
{{- /* TEMPLATE */ -}}
---
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: {{ $route.name }}
  namespace: {{ $route.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $route.additionalLabels }}
      {{- toYaml $route.additionalLabels | nindent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "05" $route.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $route.additionalAnnotations }}
      {{- toYaml $route.additionalAnnotations | nindent 4 }}
    {{- end }}
spec:
  to:
    kind: Service
    name: {{ $route.service }}
    weight: 100
  port:
    targetPort: {{ $route.port }}
  {{- $parameter := dict }}
  {{- $_ := set $parameter "fromDict" $route }}
  {{- $_ := set $parameter "avoidList" $avoidKeys }}
  {{- $routeAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
  {{- if $routeAdditionnalInfos }}
    {{- toYaml $routeAdditionnalInfos | nindent 2 }}
  {{- end }}
...
  {{- /* END RANGE */ -}}
  {{- end -}}
{{- /* END DEFINE */ -}}
{{- end -}}
