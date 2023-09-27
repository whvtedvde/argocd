{{- /* library template for eso externalsecret definition */}}
{{- /*
BEGVAL
# -- (dict) external secret operator
# @default -- see subconfig
# DOC: [eso](https://external-secrets.io/v0.8.1/)
eso:

  # -- Create eso externalsecret
  # @default -- see subconfig
  # DOC : [eso externalsecret](https://external-secrets.io/v0.8.1/api/externalsecret/)
  ## HELPER eso externalSecret AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  ### KEEP COMMAND only in yaml file
  externalSecret:
    -
      # -- (string)[REQ] name
      name: eso-externalsecret-test
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

      # -- (list)[OPT] dataFrom
      dataFrom:
        -
          # -- (dict)[OPT] extract
          ## extract secret from path in vault
          extract:
             # -- (string)[OPT] conversionStrategy
            conversionStrategy: Default
             # -- (string)[OPT] decodingStrategy
            decodingStrategy: None
             # -- (string)[OPT] key
             ## path in vault
            key: prppai/outils/stepca
      # -- (string)[OPT] refreshInterval
      refreshInterval: 1h
      # -- (dict)[OPT] secretStoreRef
      ## secretStore configuration (vault connexion)
      secretStoreRef:
          # -- (string)[OPT] kind
        kind: SecretStore
          # -- (string)[OPT] name
        name: secretstore-test
      # -- (dict)[OPT] target
      ## Secret where save information to
      target:
          # -- (string)[OPT] refreshInterval
        creationPolicy: Owner
          # -- (string)[OPT] refreshInterval
        deletionPolicy: Retain
          # -- (string)[OPT] refreshInterval
        name: secret-sync-vault-stepca
ENDVAL

*/}}
{{- define "sharedlibraries.eso_externalsecret" -}}
  {{- /* Validation GENERAL */}}

  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.eso ) }}
    {{- fail "eso_externalsecret template loaded without eso object" }}
  {{- end }}

	{{- if or ( not ( hasKey $.Values.eso "enable" ) ) ( and ( hasKey $.Values.eso "enable" ) ( $.Values.eso.enable ) ) }}

  {{- if and (not $.Values.eso.externalSecret) }}
    {{- fail "eso_externalsecret template loaded without eso.externalSecret object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all externalSecret instance
  #################################
  */}}
  {{- range $externalSecret := $.Values.eso.externalSecret }}
    {{- /* DEBUG include "sharedlibraries.dump" $externalSecret */}}

    {{- /*
    #################################
    CHECK mandatory externalSecret values
    #################################
    */}}

    {{- /* CHECK externalSecret.name */}}
    {{- if not $externalSecret.name }}
      {{- fail "No name set inside eso.externalSecret object" }}
    {{- end }}

    {{- /* CHECK externalSecret.namespace */}}
    {{- if not $externalSecret.namespace }}
      {{- fail "No namespace set inside eso.externalSecret object" }}
    {{- end }}

    {{- /* CHECK externalSecret.additionalLabels */}}
    {{- if and ( $externalSecret.additionalLabels ) ( not ( kindIs "map" $externalSecret.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside eso.externalSecret object but type is :%s" ( kindOf $externalSecret.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK externalSecret.additionalAnnotations */}}
    {{- if and ( $externalSecret.additionalAnnotations) ( not ( kindIs "map" $externalSecret.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside eso.externalSecret object but type is :%s" ( kindOf $externalSecret.additionalAnnotations  ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ $externalSecret.name }}
  namespace: {{ $externalSecret.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $externalSecret.additionalLabels }}
{{ toYaml $externalSecret.additionalLabels | indent 4 }}
    {{- /* END IF externalsecret.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $externalSecret.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $externalSecret.additionalAnnotations }}
{{ toYaml $externalSecret.additionalAnnotations | indent 4 }}
    {{- /* END IF externalsecret.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameterexternalsecret := dict }}
    {{- $_ := set $parameterexternalsecret "fromDict" $externalSecret }}
    {{- $_ := set $parameterexternalsecret "avoidList" $avoidKeys }}
    {{- $externalSecretAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterexternalsecret ) }}
    {{- if $externalSecretAdditionnalInfos }}
{{ toYaml $externalSecretAdditionnalInfos | indent 2 }}
    {{- /* END IF externalsecretAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE externalsecret */}}
  {{- end }}
  {{- /* END RANGE enable eso */}}
	{{- end }}
{{- /* END DEFINE */}}
{{- end -}}
