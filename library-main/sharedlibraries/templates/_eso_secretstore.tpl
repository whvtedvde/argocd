{{/* library template for eso secretstore definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################

# -- (dict) external secret operator
# @default -- see subconfig
# DOC: [eso](https://external-secrets.io/v0.8.1/)
eso:
  # -- Create eso secretstore
  # @default -- see subconfig
  # DOC : [eso secretstore](https://external-secrets.io/v0.8.1/api/secretstore/)
  ## HELPER eso secretStore AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,provider
  secretStore:
    -
      # -- (string)[REQ] name
      name: eso-secretstore-test
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

      # -- (dict)[REQ] provider
      provider:

        # -- (dict)[REQ] vault
        ## if provider is vault
        ## ELSE no validation
        ## HELPER vault AdditionnalInfos
        ## write as YAML (without formating or validation)  everything except:
        ## auth,server
        vault:
          # -- (dict)[REQ] auth
          ## HELPER vault.auth AdditionnalInfos
          ## write as YAML (without formating or validation)
          auth:
            # -- (dict)[REQ] kubernetes
            kubernetes:
              # -- (string)[REQ] mountPath
              mountPath: k8spaiprp
              # -- (string)[REQ] role
              role: esooutils
              # -- (dict)[REQ] serviceAccountRef
              serviceAccountRef:
                # -- (string)[REQ] name
                name: sa-vault-auth-outils

            # HELPER provider.vault.auth AdditionnalInfos
            # write as YAML (without formating or validation)

          # -- (string)[REQ] server
          server: 'https://vault-oab.si.fr.intraorange:8200'

          # -- (dict)[REQ] caProvider
          caProvider:
            # -- (string)[REQ] path
            key: tls.crt
            # -- (string)[REQ] path
            name: vault-ca
            # -- (string)[REQ] path
            type: Secret
          # -- (string)[REQ] path
          path: pf
          # -- (string)[REQ] version
          version: v1

*/}}
{{- define "sharedlibraries.eso_secretstore" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.eso  */}}
  {{- if and ( not $.Values.eso ) }}
    {{- fail "eso_secretstore template loaded without eso object" }}
  {{- end }}
  {{/* CHECK $.Values.eso.secretStore  */}}
  {{- if and (not $.Values.eso.secretStore) }}
    {{- fail "eso_secretstore template loaded without eso.secretStore object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "provider" ) }}
  {{- range $secretStore := $.Values.eso.secretStore }}
    {{/* DEBUG include "sharedlibraries.dump" $secretStore */}}
    {{/*
    ######################################
    Validation Mandatory Variables secretstore
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $secretStore.name
    ######################################
    */}}
    {{- if not $secretStore.name }}
      {{- fail "No name set inside eso.secretStore object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $secretStore.namespace
    ######################################
    */}}
    {{- if not $secretStore.namespace }}
      {{- fail "No namespace set inside eso.secretStore object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $secretStore.additionalLabels
    ######################################
    */}}
    {{- if and ( $secretStore.additionalLabels ) ( not (kindIs "map" $secretStore.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside eso.secretStore object but type is :%s" ( kindOf $secretStore.additionalLabels )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $secretStore.additionalAnnotations
    ######################################
    */}}
    {{- if and ($secretStore.additionalAnnotations) (not (kindIs "map" $secretStore.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside eso.secretStore object but type is :%s" ( kindOf $secretStore.additionalAnnotations )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK provider $secretStore.provider
    ######################################
    */}}
    {{- if not $secretStore.provider  }}
      {{- fail "No provider  set inside secretstore.provider object" }}
    {{- end }}
    {{- if and ($secretStore.provider) (not (kindIs "map" $secretStore.provider)) }}
      {{- fail (printf "provider is not a DICT inside secretstore.provider object but type is :%s" ( kindOf $secretStore.provider )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK VAULT PROVIDER $secretStore.provider
    ######################################
    */}}
    {{- if hasKey $secretStore.provider "vault" }}
      {{- $parameterCheckDictSecretStoreVault := dict }}
      {{- $parameterCheckDictSecretStoreVaultMandatoryKeys := ( list "auth" "server" ) }}
      {{- $_ := set $parameterCheckDictSecretStoreVault "fromDict" $secretStore.provider }}
      {{- $_ := set $parameterCheckDictSecretStoreVault "masterKey" "vault" }}
      {{- $_ := set $parameterCheckDictSecretStoreVault "baseKey" "secretStore.provider" }}
      {{- $_ := set $parameterCheckDictSecretStoreVault "mandatoryKeys" $parameterCheckDictSecretStoreVaultMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictSecretStoreVault }}
    {{- end }}
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: {{ $secretStore.name }}
  namespace: {{ $secretStore.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $secretStore.additionalLabels }}
{{ toYaml $secretStore.additionalLabels | indent 4 }}
    {{/* END IF secretstore.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $secretStore.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $secretStore.additionalAnnotations }}
{{ toYaml $secretStore.additionalAnnotations | indent 4 }}
    {{/* END IF secretstore.additionalAnnotations */}}
    {{- end }}
spec:
  provider:
    {{- $parameterSecretStoreProvider := dict }}
    {{- $avoidKeysSecretStoreProvider := list }}
    {{- $_ := set $parameterSecretStoreProvider "fromDict" $secretStore.provider }}
    {{- $_ := set $parameterSecretStoreProvider "avoidList" $avoidKeysSecretStoreProvider }}
    {{- $secretStoreProviderAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterSecretStoreProvider ) }}
    {{- if $secretStoreProviderAdditionnalInfos }}
{{ toYaml $secretStoreProviderAdditionnalInfos | indent 6 }}
    {{/* END IF secretStoreProviderAdditionnalInfos */}}
    {{- end }}
    {{- $parametersecretstore := dict }}
    {{- $_ := set $parametersecretstore "fromDict" $secretStore }}
    {{- $_ := set $parametersecretstore "avoidList" $avoidKeys }}
    {{- $secretStoreAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametersecretstore ) }}
    {{- if $secretStoreAdditionnalInfos }}
{{ toYaml $secretStoreAdditionnalInfos | indent 2 }}
    {{/* END IF secretstoreAdditionnalInfos */}}
    {{- end }}
...
  {{/* END RANGE secretstore */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
