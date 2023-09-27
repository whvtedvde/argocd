{{- /* library template for eso operatorconfig definition */}}
{{- /*
BEGVAL
# -- (dict) external secret operator
# @default -- see subconfig
# DOC: [eso](https://external-secrets.io/v0.8.1/)
eso:
  # -- Create eso operatorConfig
  # @default -- see subconfig
  # DOC : [eso operatorConfig](https://external-secrets.io/v0.8.1/api/operatorConfig/)
  ## HELPER eso operatorConfig AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  ### KEEP COMMAND only in yaml file
  operatorConfig:
    -
      # -- (string)[REQ] name
      name: eso-operatorConfig
      # -- (string)[REQ] namespace
      namespace: external-secrets-operator
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

      # this must be set to false when using olm
      installCRDs: false
      # Default values copied from <project_dir>/helm-charts/external-secrets/values.yaml
      replicaCount: 1
      image:
        repository: ghcr.io/external-secrets/external-secrets
        pullPolicy: IfNotPresent
        tag: ""
      crds:
        createClusterExternalSecret: true
        createClusterSecretStore: true


ENDVAL

*/}}
{{- define "sharedlibraries.eso_operatorconfig" -}}
  {{- /* Validation GENERAL */}}

  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.eso ) }}
    {{- fail "eso_operatorconfig template loaded without eso object" }}
  {{- end }}

	{{- if or ( not ( hasKey $.Values.eso "enable" ) ) ( and ( hasKey $.Values.eso "enable" ) ( $.Values.eso.enable ) ) }}

  {{- if and (not $.Values.eso.operatorConfig) }}
    {{- fail "eso_operatorconfig template loaded without eso.operatorConfig object" }}
  {{- end }}



  {{- $apiVersion := ( default "00" $.Values.eso.version ) }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all operatorConfig instance
  #################################
  */}}
  {{- range $operatorConfig := $.Values.eso.operatorConfig }}
    {{- /* DEBUG include "sharedlibraries.dump" $operatorConfig */}}

    {{- /*
    #################################
    CHECK mandatory operatorConfig values
    #################################
    */}}

    {{- /* CHECK operatorConfig.name */}}
    {{- if not $operatorConfig.name }}
      {{- fail "No name set inside eso.operatorConfig object" }}
    {{- end }}

    {{- /* CHECK operatorConfig.namespace */}}
    {{- if not $operatorConfig.namespace }}
      {{- fail "No namespace set inside eso.operatorConfig object" }}
    {{- end }}

    {{- /* CHECK operatorConfig.additionalLabels */}}
    {{- if and ( $operatorConfig.additionalLabels ) ( not ( kindIs "map" $operatorConfig.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside eso.operatorConfig object but type is :%s" ( kindOf $operatorConfig.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK operatorConfig.additionalAnnotations */}}
    {{- if and ( $operatorConfig.additionalAnnotations) ( not ( kindIs "map" $operatorConfig.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside eso.operatorConfig object but type is :%s" ( kindOf $operatorConfig.additionalAnnotations  ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
{{- if eq $apiVersion "00" }}
apiVersion: operator.external-secrets.io/v1alpha1
{{- else if semverCompare "0.9.0" $apiVersion }}
apiVersion: operator.external-secrets.io/v1beta1
{{- else }}
apiVersion: operator.external-secrets.io/v1beta1
{{- end }}
kind: OperatorConfig
metadata:
  name: {{ $operatorConfig.name }}
  namespace: {{ $operatorConfig.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $operatorConfig.additionalLabels }}
{{ toYaml $operatorConfig.additionalLabels | indent 4 }}
    {{- /* END IF operatorConfig.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $operatorConfig.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $operatorConfig.additionalAnnotations }}
{{ toYaml $operatorConfig.additionalAnnotations | indent 4 }}
    {{- /* END IF operatorConfig.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameterexternalsecret := dict }}
    {{- $_ := set $parameterexternalsecret "fromDict" $operatorConfig }}
    {{- $_ := set $parameterexternalsecret "avoidList" $avoidKeys }}
    {{- $externalSecretAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterexternalsecret ) }}
    {{- if $externalSecretAdditionnalInfos }}
{{ toYaml $externalSecretAdditionnalInfos | indent 2 }}
    {{- /* END IF externalsecretAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE operatorConfig */}}
  {{- end }}
  {{- /* END RANGE enable eso */}}
	{{- end }}
{{- /* END DEFINE */}}
{{- end -}}
