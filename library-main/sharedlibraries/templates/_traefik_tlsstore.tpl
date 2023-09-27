{{- /* library template for traefik tlsstore definition */}}
{{- /*
BEGVAL
# -- (dict) TRAEFIK definition
# @default -- see subconfig
# DOC: [traefik](https://doc.traefik.io/traefik/)
traefik:
  # -- Create TRAEFIK tlsstore
  # @default -- see subconfig
  # DOC : [traefik tlsstore](https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-tlsstore)
  # DOC : [traefik tlsstore](https://doc.traefik.io/traefik/v2.9/https/tls/#certificates-stores)
  ## HELPER TRAEFIK tlsStore AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  tlsStore:
    -
      # -- (string)[REQ] name
      name: traefik-tlsstore
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

      # -- (list)[OPT] certificates
      certificates:
        - secretName: foo
        - secretName: bar
      # -- (dict)[OPT] defaultCertificate
      defaultCertificate:
        # -- (string)[OPT] secretName
        secretName: secret

ENDVAL
*/}}
{{- define "sharedlibraries.traefik_tlsstore" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_tlsstore template loaded without traefik object" }}
  {{- end }}

  {{- if and (not $.Values.traefik.tlsStore ) }}
    {{- fail "traefik_tlsstore template loaded without traefik.tlsStore object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all tlsStore instance
  #################################
  */}}
  {{- range $tlsStore := $.Values.traefik.tlsStore }}
    {{- /* DEBUG include "sharedlibraries.dump" $tlsStore */}}
    {{- /*
    #################################
    CHECK mandatory tlsStore values
    #################################
    */}}
    {{- /* CHECK tlsStore.name */}}
    {{- if not $tlsStore.name }}
      {{- fail "No name set inside traefik.tlsStore object" }}
    {{- end }}

    {{- /* CHECK tlsStore.namespace */}}
    {{- if not $tlsStore.namespace }}
      {{- fail "No namespace set inside traefik.tlsStore object" }}
    {{- end }}

    {{- /* CHECK tlsStore.additionalLabels */}}
    {{- if and ( $tlsStore.additionalLabels ) ( not ( kindIs "map" $tlsStore.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside traefik.tlsStore object but type is :%s" ( kindOf $tlsStore.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK tlsStore.additionalAnnotations */}}
    {{- if and ( $tlsStore.additionalAnnotations ) ( not ( kindIs "map" $tlsStore.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside traefik.tlsStore object but type is :%s" ( kindOf $tlsStore.additionalAnnotations  ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: traefik.io/v1alpha1
kind: TLSStore
metadata:
  name: {{ $tlsStore.name }}
  namespace: {{ $tlsStore.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $tlsStore.additionalLabels }}
{{ toYaml $tlsStore.additionalLabels | indent 4 }}
    {{- /* END IF tlsstore.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $tlsStore.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $tlsStore.additionalAnnotations }}
{{ toYaml $tlsStore.additionalAnnotations | indent 4 }}
    {{- /* END IF tlsstore.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parametertlsstore := dict }}
    {{- $_ := set $parametertlsstore "fromDict" $tlsStore }}
    {{- $_ := set $parametertlsstore "avoidList" $avoidKeys }}
    {{- $tlsStoreAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametertlsstore ) }}
    {{- if $tlsStoreAdditionnalInfos }}
{{ toYaml $tlsStoreAdditionnalInfos | indent 2 }}
    {{- /* END IF tlsstoreAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE tlsstore */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
