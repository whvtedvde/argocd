{{- /*library template for configmap definition */}}
{{- /*
BEGVAL

# -- (dict) configMap
# @default -- see subconfig
# DOC: [subconfig](https://docs.openshift.com/container-platform/4.12/nodes/pods/nodes-pods-configmaps.html)
configMap:
  # -- Create configMap
  # @default -- see subconfig
  # DOC : [subconfig](https://kubernetes.io/docs/concepts/configuration/configMap/)
  ## HELPER configMap AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  -
    # -- (string)[REQ] name
    name: configMap-test
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
    syncWave: 00

    # -- (dict)[OPT] data
    data:
      test.yml: |-
        example de configuration !

ENDVAL

*/}}
{{- define "sharedlibraries.configmap" -}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}
  {{- if and (not $.Values.configMap) }}
    {{- fail "configMap template loaded without configMap object" }}
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
  {{- range $configMap := $.Values.configMap }}
    {{- /*DEBUG include "sharedlibraries.dump" $configMap */}}
    {{- /*
    #################################
    CHECK mandatory installplan values
    #################################
    */}}
    {{- /* CHECK configMap.name */}}
    {{- if not $configMap.name }}
      {{- fail "No name set inside configMap object" }}
    {{- end }}

    {{- /* CHECK configMap.namespace */}}
    {{- if not $configMap.namespace }}
      {{- fail "No namespace set inside configMap object" }}
    {{- end }}

    {{- /* CHECK configMap.additionalLabels */}}
    {{- if and ( $configMap.additionalLabels) ( not ( kindIs "map" $configMap.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside metalLB.configMap object but type is :%s" ( kindOf $configMap.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK configMap.additionalAnnotations */}}
    {{- if and ( $configMap.additionalAnnotations) ( not ( kindIs "map" $configMap.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside metalLB.configMap object but type is :%s" ( kindOf $configMap.additionalAnnotations ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $configMap.name }}
  namespace: {{ $configMap.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $configMap.additionalLabels }}
{{ toYaml $configMap.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "02" $configMap.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $configMap.additionalAnnotations }}
{{ toYaml $configMap.additionalAnnotations | indent 4 }}
    {{- end }}
    {{- $parameterConfigMap := dict }}
    {{- $_ := set $parameterConfigMap "fromDict" $configMap }}
    {{- $_ := set $parameterConfigMap "avoidList" $avoidKeys }}
    {{- $configMapAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterConfigMap ) }}
    {{- if $configMapAdditionnalInfos }}
{{ toYaml $configMapAdditionnalInfos | indent 0 }}
    {{- /*END IF configMapAdditionnalInfos */}}
    {{- end }}
...
  {{- /*END RANGE */}}
  {{- end }}
{{- /*END DEFINE */}}
{{- end -}}
