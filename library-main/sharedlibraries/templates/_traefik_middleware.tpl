{{- /* library template for traefik middleware definition */}}
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
  ## HELPER TRAEFIK middleware AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  middleware:
    -
      # -- (string)[REQ] name
      name: traefik-middleware-test
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
      basicAuth:
        # -- (string)[OPT] secret
        secret: traefik-dashboard-auth-secret

ENDVAL
*/}}
{{- define "sharedlibraries.traefik_middleware" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_middleware template loaded without traefik object" }}
  {{- end }}

  {{- if and (not $.Values.traefik.middleware ) }}
    {{- fail "traefik_middleware template loaded without traefik.middleware object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all middleware instance
  #################################
  */}}
  {{- range $middleware := $.Values.traefik.middleware }}
    {{- /* DEBUG include "sharedlibraries.dump" $middleware */}}
    {{- /*
    #################################
    CHECK mandatory middleware values
    #################################
    */}}
    {{- /* CHECK middleware.name */}}
    {{- if not $middleware.name }}
      {{- fail "No name set inside traefik.middleware object" }}
    {{- end }}

    {{- /* CHECK middleware.namespace */}}
    {{- if not $middleware.namespace }}
      {{- fail "No namespace set inside traefik.middleware object" }}
    {{- end }}

    {{- /* CHECK middleware.additionalLabels */}}
    {{- if and ( $middleware.additionalLabels ) ( not ( kindIs "map" $middleware.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside traefik.middleware object but type is :%s" ( kindOf $middleware.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK middleware.additionalAnnotations */}}
    {{- if and ( $middleware.additionalAnnotations ) ( not ( kindIs "map" $middleware.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside traefik.middleware object but type is :%s" ( kindOf $middleware.additionalAnnotations  ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: {{ $middleware.name }}
  namespace: {{ $middleware.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $middleware.additionalLabels }}
{{ toYaml $middleware.additionalLabels | indent 4 }}
    {{- /* END IF middleware.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $middleware.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $middleware.additionalAnnotations }}
{{ toYaml $middleware.additionalAnnotations | indent 4 }}
    {{- /* END IF middleware.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parametermiddleware := dict }}
    {{- $_ := set $parametermiddleware "fromDict" $middleware }}
    {{- $_ := set $parametermiddleware "avoidList" $avoidKeys }}
    {{- $middlewareAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametermiddleware ) }}
    {{- if $middlewareAdditionnalInfos }}
{{ toYaml $middlewareAdditionnalInfos | indent 2 }}
    {{- /* END IF middlewareAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE middleware */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
