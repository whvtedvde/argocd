{{- /* library template for Awx instance definition */}}
{{- /*
BEGVAL
# -- (dict) awx
# @default -- see subconfig
awx:
  # -- Create awx awx
  # @default -- see subconfig
  ## HELPER installplan AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  awx:
    -
      # -- (string)[REQ] name
      # @default -- awx
      name: awx
      # -- (string)[REQ] namespace
      # @default -- awx-system
      namespace: awx-system

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
      syncWave: 03
ENDVAL
*/}}

{{- define "sharedlibraries.awx_awx" -}}

  {{- /* Validation GENERAL */}}

  {{- /* CHECK mandatory global values */}}

  {{- if and ( not $.Values.awx ) }}
    {{- fail "awx template loaded without awx object" }}
  {{- end }}

  {{- if and ( not $.Values.awx.awx ) }}
    {{- fail "awxtemplate loaded without awx.awx object" }}
  {{- end }}

  {{- /* CREATE global avoid keys	*/}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave") }}

  {{- /* LOOP all awx instance	*/}}
  {{- range $awx := $.Values.awx.awx }}

    {{- /* DEBUG include "sharedlibraries.dump" $awx */}}

    {{- /* CHECK mandatory awx values */}}

    {{- /* CHECK awx.name */}}
    {{- if not $awx.name }}
      {{- fail "No name set inside awx.awx object" }}
    {{- end }}

    {{- /* CHECK awx.namespace */}}
    {{- if not $awx.namespace }}
      {{- fail "No namespace set inside awx.awx object" }}
    {{- end }}

    {{- /* CHECK KIND awx.additionalLabels */}}
    {{- if and ( $awx.additionalLabels ) ( not ( kindIs "map" $awx.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside awx.awx object but type is :%s" ( kindOf $awx.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK KIND awx.additionalAnnotations */}}
    {{- if and ( $awx.additionalAnnotations ) ( not ( kindIs "map" $awx.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside awx.awx object but type is :%s" ( kindOf $awx.additionalAnnotations ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: {{ $awx.name }}
  namespace: {{ $awx.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $awx.additionalLabels }}
{{ toYaml $awx.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "03" $awx.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $awx.additionalAnnotations }}
{{ toYaml $awx.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
	{{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $awx }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $awxAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $awxAdditionnalInfos }}
{{ toYaml $awxAdditionnalInfos | indent 2 }}
    {{- /* END IF $awxAdditionnalInfos  */}}
    {{- end }}
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
