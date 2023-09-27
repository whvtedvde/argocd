{{- /* library template for eso clusterSecretStore definition */}}
{{- /* Parametre / Values
BEGVAL
# -- (dict) external secret operator
# @default -- see subconfig
# DOC: [eso](https://external-secrets.io/v0.8.1/)
eso:
  # -- Create eso clusterSecretStore
  # @default -- see subconfig
  # DOC : [eso clusterSecretStore](https://external-secrets.io/v0.8.1/api/clusterSecretStore/)
  ## HELPER eso clusterSecretStore AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,provider
  clusterSecretStore:
    -
      # -- (string)[REQ] name
      name: eso-clusterSecretStore-test

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
                # -- (string)[REQ] namespace
                namespace:

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
ENDVAL

*/}}
{{- define "sharedlibraries.eso_clustersecretstore" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}
  {{- if and ( not $.Values.eso ) }}
    {{- fail "eso_clustersecretstore template loaded without eso object" }}
  {{- end }}

  {{- if and (not $.Values.eso.clusterSecretStore) }}
    {{- fail "eso_clustersecretstore template loaded without eso.clusterSecretStore object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "provider" ) }}
  {{- /*
  #################################
  LOOP all instance
  #################################
  */}}
  {{- range $clusterSecretStore := $.Values.eso.clusterSecretStore }}
    {{- /* DEBUG include "sharedlibraries.dump" $clusterSecretStore */}}
    {{- /*
    #################################
    CHECK mandatory ipPool values
    #################################
    */}}
    {{- /* CHECK clusterSecretStore.name */}}
    {{- if not $clusterSecretStore.name }}
      {{- fail "No name set inside eso.clusterSecretStore object" }}
    {{- end }}

    {{- /* CHECK clusterSecretStore.additionalLabels */}}
    {{- if and ( $clusterSecretStore.additionalLabels ) ( not ( kindIs "map" $clusterSecretStore.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside eso.clusterSecretStore object but type is :%s" ( kindOf $clusterSecretStore.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK clusterSecretStore.additionalAnnotations */}}
    {{- if and ( $clusterSecretStore.additionalAnnotations ) ( not ( kindIs "map" $clusterSecretStore.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside eso.clusterSecretStore object but type is :%s" ( kindOf $clusterSecretStore.additionalAnnotations  ) ) }}
    {{- end }}

    {{- /* CHECK clusterSecretStore.provider */}}
    {{- if not $clusterSecretStore.provider  }}
      {{- fail "No provider  set inside clusterSecretStore.provider object" }}
    {{- end }}
    {{- if and ( $clusterSecretStore.provider) ( not ( kindIs "map" $clusterSecretStore.provider ) ) }}
      {{- fail ( printf "provider is not a DICT inside clusterSecretStore.provider object but type is :%s" ( kindOf $clusterSecretStore.provider  ) ) }}
    {{- end }}

    {{- /* CHECK clusterSecretStore.provider */}}
    {{- if hasKey $clusterSecretStore.provider "vault" }}
      {{- $parameterCheckDictclusterSecretStoreVault := dict }}
      {{- $parameterCheckDictclusterSecretStoreVaultMandatoryKeys := ( list "auth" "server" ) }}
      {{- $_ := set $parameterCheckDictclusterSecretStoreVault "fromDict" $clusterSecretStore.provider }}
      {{- $_ := set $parameterCheckDictclusterSecretStoreVault "masterKey" "vault" }}
      {{- $_ := set $parameterCheckDictclusterSecretStoreVault "baseKey" "clusterSecretStore.provider" }}
      {{- $_ := set $parameterCheckDictclusterSecretStoreVault "mandatoryKeys" $parameterCheckDictclusterSecretStoreVaultMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictclusterSecretStoreVault }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: {{ $clusterSecretStore.name }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $clusterSecretStore.additionalLabels }}
{{ toYaml $clusterSecretStore.additionalLabels | indent 4 }}
    {{- /* END IF clusterSecretStore.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $clusterSecretStore.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $clusterSecretStore.additionalAnnotations }}
{{ toYaml $clusterSecretStore.additionalAnnotations | indent 4 }}
    {{- /* END IF clusterSecretStore.additionalAnnotations */}}
    {{- end }}
spec:
  provider:
    {{- $parameterclusterSecretStoreProvider := dict }}
    {{- $avoidKeysclusterSecretStoreProvider := list }}
    {{- $_ := set $parameterclusterSecretStoreProvider "fromDict" $clusterSecretStore.provider }}
    {{- $_ := set $parameterclusterSecretStoreProvider "avoidList" $avoidKeysclusterSecretStoreProvider }}
    {{- $clusterSecretStoreProviderAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterclusterSecretStoreProvider ) }}
    {{- if $clusterSecretStoreProviderAdditionnalInfos }}
{{ toYaml $clusterSecretStoreProviderAdditionnalInfos | indent 4 }}
    {{- /* END IF clusterSecretStoreProviderAdditionnalInfos */}}
    {{- end }}
    {{- $parameterclusterSecretStore := dict }}
    {{- $_ := set $parameterclusterSecretStore "fromDict" $clusterSecretStore }}
    {{- $_ := set $parameterclusterSecretStore "avoidList" $avoidKeys }}
    {{- $clusterSecretStoreAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterclusterSecretStore ) }}
    {{- if $clusterSecretStoreAdditionnalInfos }}
{{ toYaml $clusterSecretStoreAdditionnalInfos | indent 2 }}
    {{- /* END IF clusterSecretStoreAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE clusterSecretStore */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
