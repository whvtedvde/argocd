{{- /* library template for traefik traefikservice definition */}}
{{- /*
BEGVAL

# -- (dict) TRAEFIK definition
# @default -- see subconfig
# DOC: [traefik](https://doc.traefik.io/traefik/)
traefik:
  # -- Create TRAEFIK traefikservice
  # @default -- see subconfig
  # DOC : [traefik traefikservice](https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-traefikservice)
  # DOC : [traefik traefikservice](https://doc.traefik.io/traefik/v2.9/routing/services/)
  ## HELPER TRAEFIK traefikService AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  traefikService:
    -
      # -- (string)[REQ] name
      name: traefik-traefikserviceweighted
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

      # -- (dict)[OPT] weighted
      weighted:
        # -- (list)[OPT] services
        services:
          -
            # -- (string)[OPT] name
            name: svc1
            # -- (int)[OPT] port
            port: 80
            # -- (int)[OPT] weight
            weight: 1
          -
            # -- (string)[OPT] name
            name: wrr2
            # -- (string)[OPT] kind
            kind: TraefikService
            # -- (int)[OPT] weight
            weight: 1
          -
            # -- (string)[OPT] name
            name: mirror1
            # -- (string)[OPT] kind
            kind: TraefikService
            # -- (int)[OPT] weight
            weight: 1
    -
      # -- (string)[REQ] name
      name: traefik-traefikservicemirrored
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

      # -- (dict)[OPT] mirroring
      mirroring:
        # -- (string)[OPT] name
        name: svc1
        # -- (int)[OPT] port
        port: 80
        # -- (list)[OPT] mirrors
        mirrors:
          -
            # -- (string)[OPT] name
            name: svc2
            # -- (int)[OPT] port
            port: 80
            # -- (int)[OPT] percent
            percent: 20
          -
            # -- (string)[OPT] name
            name: svc3
            # -- (string)[OPT] kind
            kind: TraefikService
            # -- (int)[OPT] percent
            percent: 20

ENDVAL
*/}}
{{- define "sharedlibraries.traefik_traefikservice" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_traefikservice template loaded without traefik object" }}
  {{- end }}
  {{- if and (not $.Values.traefik.traefikService ) }}
    {{- fail "traefik_traefikservice template loaded without traefik.traefikService object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all installplan instance
  #################################
  */}}
  {{- range $traefikService := $.Values.traefik.traefikService }}
    {{- /* DEBUG include "sharedlibraries.dump" $traefikService */}}
    {{- /*
    #################################
    CHECK mandatory traefikService values
    #################################
    */}}
    {{- /* CHECK traefikService.name */}}
    {{- if not $traefikService.name }}
      {{- fail "No name set inside traefik.traefikService object" }}
    {{- end }}

    {{- /* CHECK traefikService.namespace */}}
    {{- if not $traefikService.namespace }}
      {{- fail "No namespace set inside traefik.traefikService object" }}
    {{- end }}

    {{- /* CHECK traefikService.additionalLabels */}}
    {{- if and ( $traefikService.additionalLabels ) ( not ( kindIs "map" $traefikService.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside traefik.traefikService object but type is :%s" ( kindOf $traefikService.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK traefikService.additionalAnnotations */}}
    {{- if and ( $traefikService.additionalAnnotations ) ( not ( kindIs "map" $traefikService.additionalAnnotations  ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside traefik.traefikService object but type is :%s" ( kindOf $traefikService.additionalAnnotations  ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: traefik.io/v1alpha1
kind: TraefikService
metadata:
  name: {{ $traefikService.name }}
  namespace: {{ $traefikService.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $traefikService.additionalLabels }}
{{ toYaml $traefikService.additionalLabels | indent 4 }}
    {{- /* END IF traefikservice.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $traefikService.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $traefikService.additionalAnnotations }}
{{ toYaml $traefikService.additionalAnnotations | indent 4 }}
    {{- /* END IF traefikservice.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parametertraefikservice := dict }}
    {{- $_ := set $parametertraefikservice "fromDict" $traefikService }}
    {{- $_ := set $parametertraefikservice "avoidList" $avoidKeys }}
    {{- $traefikServiceAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametertraefikservice ) }}
    {{- if $traefikServiceAdditionnalInfos }}
{{ toYaml $traefikServiceAdditionnalInfos | indent 2 }}
    {{- /* END IF traefikserviceAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE traefikservice */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
