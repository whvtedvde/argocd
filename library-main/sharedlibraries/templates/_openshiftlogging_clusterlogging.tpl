{{- /* library template for Openshift Logging cluster Logging definition */}}
{{- /*
BEGVAL
# -- (dict) openshiftLogging
# @default -- see subconfig
# DOC: [openshiftLogging](https://openshiftLogging.universe.tf/)
openshiftLogging:
  # -- Create openshiftLogging clusterLogging
  # @default -- see subconfig
  ## HELPER installplan AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  clusterLogging:
    -
      # -- (string)[REQ] name
      # @default -- instance
      name: instance
      # -- (string)[REQ] namespace
      # @default -- openshift-logging
      namespace: openshift-logging

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
{{- define "sharedlibraries.openshiftlogging_clusterlogging" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
	#################################
	CHECK mandatory global values
	#################################
	*/}}
  {{- if and ( not $.Values.openshiftLogging ) }}
    {{- fail "openshiftLogging_clusterLogging template loaded without openshiftLogging object" }}
  {{- end }}

  {{- if and ( not $.Values.openshiftLogging.clusterLogging ) }}
    {{- fail "openshiftLogging_clusterLogging template loaded without openshiftLogging.clusterLogging object" }}
  {{- end }}

	{{- /*
	#################################
	CREATE global avoid keys
	#################################
	*/}}
	{{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave") }}

	{{- /*
	#################################
	LOOP all clusterLogging instance
	#################################
	*/}}
  {{- range $clusterLogging := $.Values.openshiftLogging.clusterLogging }}
    {{- /* DEBUG include "sharedlibraries.dump" $clusterLogging */}}
    {{- /*
		#################################
		CHECK mandatory clusterLogging values
		#################################
		*/}}
    {{- /* CHECK clusterLogging.name */}}
    {{- if not $clusterLogging.name }}
      {{- fail "No name set inside openshiftLogging.clusterLogging object" }}
    {{- end }}

    {{- /* CHECK clusterLogging.namespace */}}
    {{- if not $clusterLogging.namespace }}
      {{- fail "No namespace set inside openshiftLogging.clusterLogging object" }}
    {{- end }}

    {{- /* CHECK KIND clusterLogging.additionalLabels */}}
    {{- if and ( $clusterLogging.additionalLabels) ( not ( kindIs "map" $clusterLogging.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside openshiftLogging.clusterLogging object but type is :%s" ( kindOf $clusterLogging.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK KIND clusterLogging.additionalAnnotations */}}
    {{- if and ( $clusterLogging.additionalAnnotations) ( not ( kindIs "map" $clusterLogging.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside openshiftLogging.clusterLogging object but type is :%s" ( kindOf $clusterLogging.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK KIND $clusterLogging.additionalAnnotations */}}
    {{- if and ( $clusterLogging.additionalAnnotations) ( not ( kindIs "map" $clusterLogging.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside openshiftLogging.clusterLogging object but type is :%s" ( kindOf $clusterLogging.additionalAnnotations ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
kind: ClusterLogging
apiVersion: logging.openshift.io/v1
metadata:
  name: {{ $clusterLogging.name }}
  namespace: {{ $clusterLogging.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $clusterLogging.additionalLabels }}
{{ toYaml $clusterLogging.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "03" $clusterLogging.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $clusterLogging.additionalAnnotations }}
{{ toYaml $clusterLogging.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
		{{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $clusterLogging }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $clusterLoggingAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $clusterLoggingAdditionnalInfos }}
{{ toYaml $clusterLoggingAdditionnalInfos | indent 2 }}
    {{- /* END IF $clusterLoggingAdditionnalInfos  */}}
    {{- end }}
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
