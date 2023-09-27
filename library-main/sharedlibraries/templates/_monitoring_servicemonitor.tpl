{{- /* library template for monitoring  servicemonitor definition */}}
{{- /*
BEGVAL
# -- (dict) monitoring
# @default -- see subconfig
# DOC: [monitoring](https://kubernetes.io/fr/docs/concepts/monitoring-networking/service/)
# DOC: [monitoring](https://docs.openshift.com/online/pro/architecture/core_concepts/pods_and_monitoring.html#monitoring)
monitoring:
  serviceMonitor:
    # -- Create monitoring
    # @default -- see subconfig
    # DOC: [monitoring](https://kubernetes.io/fr/docs/concepts/monitoring-networking/service/)
    ## HELPER monitoring AdditionnalInfos
    ## write as YAML (without formating or validation) everything except:
    ## name, namespace, additionalLabels, additionalAnnotations, syncWave, type , ports
    -
      # -- (string)[REQ] name
      name: msm-k8spurger
      # -- (string)[REQ] namespace
      namespace: k8spurger

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

      # -- (string)[REQ] jobLabel
      jobLabel: stepca

      # -- (list)[REQ] endpoints
      endpoints:
        -
          # -- (string)[REQ] path
          path: /metrics
          # -- (string)[REQ] port name or number
          port: metrics

      # -- (dict)[REQ] selector
      ## All of the requirements, from both matchLabels and matchExpressions are ANDed together
      ## they must all be satisfied in order to match.
      selector:
        # -- (dict)[REQ] namespace labels with matchLabels
        matchLabels:
          # -- (string)[REQ] namespace labels example
          kubernetes.io/metadata.name: outils
        matchExpressions:

      # -- (dict)[REQ] namespaceSelector
      ## All of the requirements, from both matchLabels and matchExpressions are ANDed together
      ## they must all be satisfied in order to match.
      namespaceSelector:
        # -- (dict)[REQ] namespace labels with matchLabels
        matchLabels:
          # -- (string)[REQ] namespace labels example
          kubernetes.io/metadata.name: outils
        matchExpressions:

ENDVAL
*/}}
{{- define "sharedlibraries.monitoring_servicemonitor" -}}
  {{- /* Validation GENERAL */}}

  {{- /*  CHECK $.Values.monitoring  */}}
  {{- if not $.Values.monitoring }}
    {{- fail "monitoring_servicemonitor template loaded without monitoring object" }}
  {{- end }}

  {{- /*  CHECK $.Values.monitoring.serviceMonitor  */}}
  {{- if not $.Values.monitoring.serviceMonitor }}
    {{- fail "monitoring_servicemonitor template loaded without monitoring.serviceMonitor object" }}
  {{- end }}

  {{- /*  CREATE global avoid keys  */}}
  {{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "namespaceSelector" "selector" "endpoints" "jobLabel" ) }}

	{{- /*  LOOP all serviceMonitor */}}
  {{- range $serviceMonitor := $.Values.monitoring.serviceMonitor }}
    {{- /* DEBUG include "sharedlibraries.dump" $serviceMonitor */}}

    {{- /* CHECK mandatory serviceMonitor values */}}

    {{- /* CHECK serviceMonitor.name */}}
    {{- if not $serviceMonitor.name }}
      {{- fail "no name set inside monitoring.serviceMonitor object" }}
    {{- end }}

    {{- /* CHECK serviceMonitor.namespace */}}
    {{- if not $serviceMonitor.namespace }}
      {{- fail "no namespace set inside monitoring.serviceMonitor object" }}
    {{- end }}

    {{- /* CHECK serviceMonitor.additionalLabels */}}
    {{- if and ( $serviceMonitor.additionalLabels ) ( not ( kindIs "map" $serviceMonitor.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside monitoring.serviceMonitor object but type is :%s" ( kindOf $serviceMonitor.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK serviceMonitor.additionalAnnotations */}}
    {{- if and ( $serviceMonitor.additionalAnnotations ) ( not ( kindIs "map" $serviceMonitor.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside monitoring.serviceMonitor object but type is :%s" ( kindOf $serviceMonitor.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK serviceMonitor.jobLabel */}}
    {{- if not $serviceMonitor.jobLabel }}
      {{- fail "No jobLabel set inside monitoring.serviceMonitor object" }}
    {{- end }}

    {{- /* CHECK serviceMonitor.endpoints */}}
    {{- if not $serviceMonitor.endpoints }}
      {{- fail "No endpoints set inside monitoring.serviceMonitor object" }}
    {{- end }}

		{{- /* CHECK KIND and MANDATORY serviceMonitor.endpoints  */}}
		{{- $parameterCheckDictServiceMonitorEndpoints := dict }}
		{{- $parameterCheckDictServiceMonitorEndpointsMandatoryKeys := ( list "path" "port" ) }}
		{{- $_ := set $parameterCheckDictServiceMonitorEndpoints "fromDict" $serviceMonitor }}
		{{- $_ := set $parameterCheckDictServiceMonitorEndpoints "masterKey" "endpoints" }}
		{{- $_ := set $parameterCheckDictServiceMonitorEndpoints "baseKey" "monitoring" }}
		{{- $_ := set $parameterCheckDictServiceMonitorEndpoints "mandatoryKeys" $parameterCheckDictServiceMonitorEndpointsMandatoryKeys }}
		{{- include "sharedlibraries.checkVariableList" $parameterCheckDictServiceMonitorEndpoints }}


    {{/* CHECK $serviceMonitor.selector */}}
    {{- if not $serviceMonitor.selector }}
      {{- fail "No selector set inside monitoring.serviceMonitor object" }}
    {{- end }}

    {{/* CHECK $serviceMonitor.selector.matchLabels and/or matchExpressions */}}
    {{- if and ( not $serviceMonitor.selector.matchLabels ) ( not $serviceMonitor.selector.matchExpressions ) }}
      {{- fail "No matchLabels and/or matchExpressions set inside monitoring.serviceMonitor.selector object" }}
    {{- end }}

    {{- /* CHECK $serviceMonitor.namespaceSelector */}}
    {{- if not $serviceMonitor.namespaceSelector }}
      {{- fail "No namespaceSelector set inside monitoring.serviceMonitor object" }}
    {{- end }}

    {{- /* CHECK $serviceMonitor.namespaceSelector matchNames or any   */}}
    {{- if and ( not $serviceMonitor.namespaceSelector.matchNames ) ( not $serviceMonitor.namespaceSelector.any ) }}
      {{- fail "No matchNames or any set inside monitoring.serviceMonitor.namespaceSelector object" }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ $serviceMonitor.name }}
  namespace: {{ $serviceMonitor.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $serviceMonitor.additionalLabels }}
{{ toYaml $serviceMonitor.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $serviceMonitor.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $serviceMonitor.additionalAnnotations }}
{{ toYaml $serviceMonitor.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  jobLabel: {{ $serviceMonitor.jobLabel }}
  endpoints: {{ toYaml $serviceMonitor.endpoints | nindent 2 }}
  namespaceSelector:
{{ toYaml $serviceMonitor.namespaceSelector | indent 4 }}
  selector:
{{ toYaml $serviceMonitor.selector | indent 4 }}
    {{- $parameterServiceMonitor := dict }}
    {{- $_ := set $parameterServiceMonitor "fromDict" $serviceMonitor }}
    {{- $_ := set $parameterServiceMonitor "avoidList" $avoidKeys }}
    {{- $serviceMonitorAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterServiceMonitor ) }}
    {{- if $serviceMonitorAdditionnalInfos }}
{{ toYaml $serviceMonitorAdditionnalInfos | indent 2 }}
    {{/* END IF serviceMonitorAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
