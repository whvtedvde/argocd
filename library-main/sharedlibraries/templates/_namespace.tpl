{{- /* library template for  namespace definition*/}}
{{- /* Parametre / Values
BEGVAL
# -- (dict) namespace definition
# @default -- see subconfig
## :warning: BE REALLY careful with namespace handle by argoCD
## If you remove the application , ALL RESSOURCES inside this namespace will be destroyed
### This comment will be only visible in yaml file
namespace:
  -
    # -- (string)[REQ] name
    name: thisnamespace
    # -- (dict)[OPT] additionnal labels
    additionalLabels:
      # -- (string)[OPT] additionnal labels exemple
      additionalLabelsTest: test
    # -- (dict)[OPT] additionnal annotations
    additionalAnnotations:
      # -- (string)[OPT] additionnal annotations exemple
      additionalAnnotationsTest: test
    # -- (int)[OPT] ArgoCD syncwave annotation
    syncWave: -5
ENDVAL

*/}}
{{- define "sharedlibraries.namespace" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}
  {{- if not $.Values.namespace }}
    {{- fail "Namespace template loaded without namespace object" }}
  {{- end }}

  {{- /*
  #################################
  LOOP all namespace instance
  #################################
  */}}
  {{- range $namespace := $.Values.namespace }}
    {{- /* DEBUG include "sharedlibraries.dump" $namespace */}}
    {{- /*
    #################################
    CHECK mandatory namespace values
    #################################
    */}}

    {{- /* CHECK namespace.name */}}
    {{- if not ($namespace.name) }}
      {{- fail "No name set inside namespace object" }}
    {{- end }}

    {{- /* CHECK namespace.additionalLabels */}}
    {{- if and ( $namespace.additionalLabels ) ( not ( kindIs "map" $namespace.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside namespace object but type is :%s" ( kindOf $namespace.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK namespace.additionalAnnotations */}}
    {{- if and ( $namespace.additionalAnnotations ) ( not ( kindIs "map" $namespace.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside namespace object but type is :%s" ( kindOf $namespace.additionalAnnotations ) ) }}
    {{- end }}
---
apiVersion: v1
kind: Namespace
metadata:
  name: {{ $namespace.name }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $namespace.additionalLabels }}
{{ toYaml $namespace.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "-1" $namespace.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $namespace.additionalAnnotations }}
{{ toYaml $namespace.additionalAnnotations | indent 4 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
