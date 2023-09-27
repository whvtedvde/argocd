{{- /* library template for traefik middlewaretcp definition */}}
{{- /*
BEGVAL

# -- (dict) TRAEFIK definition
# @default -- see subconfig
# DOC: [traefik](https://doc.traefik.io/traefik/)
traefik:
  # -- Create TRAEFIK middleware
  # @default -- see subconfig
  # DOC : [traefik middleware](https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-middleware)
  # DOC : [traefik middleware](https://doc.traefik.io/traefik/v2.9/middlewares/http/overview/)
  ## HELPER TRAEFIK middlewaretcp AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  middlewareTCP:
    -
      # -- (string)[REQ] name
      name: traefik-middlewaretcp-test
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

      # -- (dict)[OPT] basicAuth
      inFlightConn:
          # -- (int)[OPT] amount
        amount: 10
      # -- (list)[OPT] basicAuth
      ipWhiteList:
          # -- (string)[OPT] sourceRange
        sourceRange:
          - 10.222.0.0/8

ENDVAL
*/}}
{{- define "sharedlibraries.traefik_middlewaretcp" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_middlewaretcp template loaded without traefik object" }}
  {{- end }}

  {{- if and (not $.Values.traefik.middlewareTCP ) }}
    {{- fail "traefik_middlewaretcp template loaded without traefik.middlewareTCP object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all middlewareTCP instance
  #################################
  */}}
  {{- range $middlewareTCP := $.Values.traefik.middlewareTCP }}
    {{- /* DEBUG include "sharedlibraries.dump" $middlewareTCP */}}
    {{- /*
    #################################
    CHECK mandatory middlewareTCP values
    #################################
    */}}
    {{- /* CHECK middlewareTCP.name */}}
    {{- if not $middlewareTCP.name }}
      {{- fail "No name set inside traefik.middlewareTCP object" }}
    {{- end }}

    {{- /* CHECK middlewareTCP.namespace */}}
    {{- if not $middlewareTCP.namespace }}
      {{- fail "No namespace set inside traefik.middlewareTCP object" }}
    {{- end }}

    {{- /* CHECK middlewareTCP.additionalLabels */}}
    {{- if and ( $middlewareTCP.additionalLabels ) ( not ( kindIs "map" $middlewareTCP.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside traefik.middlewareTCP object but type is :%s" ( kindOf $middlewareTCP.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK middlewareTCP.additionalAnnotations */}}
    {{- if and ( $middlewareTCP.additionalAnnotations) ( not ( kindIs "map" $middlewareTCP.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside traefik.middlewareTCP object but type is :%s" ( kindOf $middlewareTCP.additionalAnnotations  ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: traefik.io/v1alpha1
kind: middlewaretcp
metadata:
  name: {{ $middlewareTCP.name }}
  namespace: {{ $middlewareTCP.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $middlewareTCP.additionalLabels }}
{{ toYaml $middlewareTCP.additionalLabels | indent 4 }}
    {{- /* END IF middlewaretcp.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $middlewareTCP.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $middlewareTCP.additionalAnnotations }}
{{ toYaml $middlewareTCP.additionalAnnotations | indent 4 }}
    {{- /* END IF middlewaretcp.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parametermiddlewaretcp := dict }}
    {{- $_ := set $parametermiddlewaretcp "fromDict" $middlewareTCP }}
    {{- $_ := set $parametermiddlewaretcp "avoidList" $avoidKeys }}
    {{- $middlewareTCPAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametermiddlewaretcp ) }}
    {{- if $middlewareTCPAdditionnalInfos }}
{{ toYaml $middlewareTCPAdditionnalInfos | indent 2 }}
    {{- /* END IF middlewaretcpAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE middlewaretcp */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
