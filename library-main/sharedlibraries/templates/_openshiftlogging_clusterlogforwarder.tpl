{{- /* library template for Openshift Logging Cluster Log Forwarder definition */}}
{{- /*
BEGVAL
# -- (dict) openshiftLogging
# @default -- see subconfig
# DOC: [openshiftLogging](https://openshiftLogging.universe.tf/)
openshiftLogging:
  # -- Create openshiftLogging clusterLogForwarder
  # @default -- see subconfig
  ## HELPER installplan AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  clusterLogForwarder:
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
{{- define "sharedlibraries.openshiftlogging_clusterlogforwarder" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
	#################################
	CHECK mandatory global values
	#################################
	*/}}
  {{- if and ( not $.Values.openshiftLogging ) }}
    {{- fail "openshiftLogging_clusterLogForwarder template loaded without openshiftLogging object" }}
  {{- end }}

  {{- if and ( not $.Values.openshiftLogging.clusterLogForwarder ) }}
    {{- fail "openshiftLogging_clusterLogForwarder template loaded without openshiftLogging.clusterLogForwarder object" }}
  {{- end }}

	{{- /*
	#################################
	CREATE global avoid keys
	#################################
	*/}}
	{{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave") }}

	{{- /*
	#################################
	LOOP all clusterLogForwarder instance
	#################################
	*/}}
  {{- range $clusterLogForwarder := $.Values.openshiftLogging.clusterLogForwarder }}
    {{- /* DEBUG include "sharedlibraries.dump" $clusterLogForwarder */}}
    {{- /*
		#################################
		CHECK mandatory clusterLogForwarder values
		#################################
		*/}}
    {{- /* CHECK clusterLogForwarder.name */}}
    {{- if not $clusterLogForwarder.name }}
      {{- fail "No name set inside openshiftLogging.clusterLogForwarder object" }}
    {{- end }}

    {{- /* CHECK clusterLogForwarder.namespace */}}
    {{- if not $clusterLogForwarder.namespace }}
      {{- fail "No namespace set inside openshiftLogging.clusterLogForwarder object" }}
    {{- end }}

    {{- /* CHECK KIND clusterLogForwarder.additionalLabels */}}
    {{- if and ( $clusterLogForwarder.additionalLabels) ( not ( kindIs "map" $clusterLogForwarder.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside openshiftLogging.clusterLogForwarder object but type is :%s" ( kindOf $clusterLogForwarder.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK KIND clusterLogForwarder.additionalAnnotations */}}
    {{- if and ( $clusterLogForwarder.additionalAnnotations) ( not ( kindIs "map" $clusterLogForwarder.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside openshiftLogging.clusterLogForwarder object but type is :%s" ( kindOf $clusterLogForwarder.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK KIND $clusterLogForwarder.additionalAnnotations */}}
    {{- if and ( $clusterLogForwarder.additionalAnnotations) ( not ( kindIs "map" $clusterLogForwarder.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside openshiftLogging.clusterLogForwarder object but type is :%s" ( kindOf $clusterLogForwarder.additionalAnnotations ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
kind: ClusterLogForwarder
apiVersion: logging.openshift.io/v1
metadata:
  name: {{ $clusterLogForwarder.name }}
  namespace: {{ $clusterLogForwarder.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $clusterLogForwarder.additionalLabels }}
{{ toYaml $clusterLogForwarder.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "03" $clusterLogForwarder.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $clusterLogForwarder.additionalAnnotations }}
{{ toYaml $clusterLogForwarder.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
		{{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $clusterLogForwarder }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $clusterLogForwarderAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $clusterLogForwarderAdditionnalInfos }}
{{ toYaml $clusterLogForwarderAdditionnalInfos | indent 2 }}
    {{- /* END IF $clusterLogForwarderAdditionnalInfos  */}}
    {{- end }}
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
