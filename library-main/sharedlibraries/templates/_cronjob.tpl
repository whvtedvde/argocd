{{- /* library template for cronjob definition */}}
{{- /*
BEGVAL

# -- Create cronjob
# @default -- see subconfig
# DOC : [cronjob](https://docs.openshift.com/container-platform/4.13/nodes/jobs/nodes-nodes-jobs.html)
## HELPER cronjob AdditionnalInfos
## write as YAML (without formating or validation) everything except:
## name, namespace, additionalLabels, additionalAnnotations, syncWave,schedule
### KEEP COMMAND only in yaml file
cronjob:
  -
    # -- (string)[REQ] name
    name: cronjob-stepca-export
    # -- (string)[REQ] namespace
    namespace: cronjob

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
    syncWave: 01

    # -- (string)[REQ] schedule
    schedule: '@hourly'

ENDVAL
*/}}
{{- define "sharedlibraries.cronjob" -}}
  {{- /* Validation GENERAL */}}

  {{- /* CHECK mandatory global values */}}
  {{- if  not $.Values.cronjob }}
    {{- fail "cronjob template loaded without cronjob object" }}
  {{- end }}

	{{- /* CREATE global avoid keys */}}
	{{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "schedule" ) }}

	{{- /* LOOP all cronjob instance */}}
	{{- range $cronjob := $.Values.cronjob }}
		{{- /* DEBUG include "sharedlibraries.dump" $cronjob */}}
		{{- /* CHECK mandatory cronjob values */}}

		{{- /* CHECK cronjob.name */}}
		{{- if not $cronjob.name }}
			{{- fail "no name set inside cronjob object" }}
		{{- end }}

		{{- /* CHECK cronjob.namespace */}}
		{{- if not $cronjob.namespace }}
			{{- fail "no namespace set inside cronjob object" }}
		{{- end }}

		{{- /* CHECK cronjob.additionalLabels */}}
		{{- if and ( $cronjob.additionalLabels ) ( not ( kindIs "map" $cronjob.additionalLabels ) ) }}
			{{- fail ( printf "additionalLabels is not a DICT inside cronjob object but type is :%s" ( kindOf $cronjob.additionalLabels ) ) }}
		{{- end }}

		{{- /* CHECK cronjob.additionalAnnotations */}}
		{{- if and ( $cronjob.additionalAnnotations ) ( not ( kindIs "map" $cronjob.additionalAnnotations ) ) }}
			{{- fail ( printf "additionalAnnotations is not a DICT inside cronjob object but type is :%s" ( kindOf $cronjob.additionalAnnotations ) ) }}
		{{- end }}

		{{- /* CHECK cronjob.schedule */}}
		{{- if not $cronjob.schedule }}
			{{- fail "no schedule set inside cronjob object" }}
		{{- end }}

{{- /* TEMPLATE */}}
---
kind: CronJob
apiVersion: batch/v1
metadata:
  name: {{ $cronjob.name }}
  namespace: {{ $cronjob.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
      {{- if $cronjob.additionalLabels }}
{{ toYaml $cronjob.additionalLabels | indent 4 }}
      {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "01" $cronjob.syncWave | squote  }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
      {{- if $cronjob.additionalAnnotations }}
{{ toYaml $cronjob.additionalAnnotations | indent 4 }}
      {{- end }}
spec:
  schedule: {{ $cronjob.schedule | squote }}
		{{- /* Template ALL values except avoidKeys */}}
		{{- $parameter := dict }}
		{{- $_ := set $parameter "fromDict" $cronjob }}
		{{- $_ := set $parameter "avoidList" $avoidKeys }}
		{{- $cronjobAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
		{{- if $cronjobAdditionnalInfos }}
{{ toYaml $cronjobAdditionnalInfos | indent 2 }}
		{{- /* END IF $cronjobAdditionnalInfos  */}}
		{{- end }}
...
	{{- /* END RANGE */}}
	{{- end }}
{{- /* END DEFINE */}}
{{- end -}}
