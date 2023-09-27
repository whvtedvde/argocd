{{- /* library template for traefik tlsoptions definition */}}
{{- /*
BEGVAL

# -- (dict) TRAEFIK definition
# @default -- see subconfig
# DOC: [traefik](https://doc.traefik.io/traefik/)
traefik:
  # -- Create TRAEFIK tlsoptions
  # @default -- see subconfig
  # DOC : [traefik tlsoptions]https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-tlsoption
  ## HELPER TRAEFIK tlsOptions AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  tlsOptions:
    -
      # -- (string)[REQ] name
      name: traefik-tlsoptions
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

      # -- (string)[OPT] minVersion
      minVersion: VersionTLS12
      # -- (string)[OPT] maxVersion
      maxVersion: VersionTLS13
      # -- (list)[OPT] curvePreferences
      curvePreferences:
        - CurveP521
        - CurveP384
      # -- (list)[OPT] cipherSuites
      cipherSuites:
        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        - TLS_RSA_WITH_AES_256_GCM_SHA384
      # -- (dict)[OPT] clientAuth
      clientAuth:
        # -- (list)[OPT] secretNames
        secretNames:
          - secret-ca1
          - secret-ca2
        # -- (string)[OPT] clientAuthType
        clientAuthType: VerifyClientCertIfGiven
      # -- (bool)[OPT] sniStrict
      sniStrict: true
      # -- (list)[OPT] alpnProtocols
      alpnProtocols:
        - foobar

ENDVAL
*/}}
{{- define "sharedlibraries.traefik_tlsoptions" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_tlsoptions template loaded without traefik object" }}
  {{- end }}

  {{- if and (not $.Values.traefik.tlsOptions ) }}
    {{- fail "traefik_tlsoptions template loaded without traefik.tlsOptions object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all tlsOptions instance
  #################################
  */}}
  {{- range $tlsOptions := $.Values.traefik.tlsOptions }}
    {{- /* DEBUG include "sharedlibraries.dump" $tlsOptions */}}
    {{- /*
    #################################
    CHECK mandatory tlsOptions values
    #################################
    */}}
    {{- /* CHECK tlsOptions.name */}}
    {{- if not $tlsOptions.name }}
      {{- fail "No name set inside traefik.tlsOptions object" }}
    {{- end }}

    {{- /* CHECK tlsOptions.namespace */}}
    {{- if not $tlsOptions.namespace }}
      {{- fail "No namespace set inside traefik.tlsOptions object" }}
    {{- end }}

    {{- /* CHECK tlsOptions.additionalLabels */}}
    {{- if and ( $tlsOptions.additionalLabels ) ( not ( kindIs "map" $tlsOptions.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside traefik.tlsOptions object but type is :%s" ( kindOf $tlsOptions.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK tlsOptions.additionalAnnotations */}}
    {{- if and ( $tlsOptions.additionalAnnotations ) ( not ( kindIs "map" $tlsOptions.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside traefik.tlsOptions object but type is :%s" ( kindOf $tlsOptions.additionalAnnotations  ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: traefik.io/v1alpha1
kind: TLSOption
metadata:
  name: {{ $tlsOptions.name }}
  namespace: {{ $tlsOptions.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $tlsOptions.additionalLabels }}
{{ toYaml $tlsOptions.additionalLabels | indent 4 }}
    {{- /* END IF tlsoptions.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $tlsOptions.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $tlsOptions.additionalAnnotations }}
{{ toYaml $tlsOptions.additionalAnnotations | indent 4 }}
    {{- /* END IF tlsoptions.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parametertlsoptions := dict }}
    {{- $_ := set $parametertlsoptions "fromDict" $tlsOptions }}
    {{- $_ := set $parametertlsoptions "avoidList" $avoidKeys }}
    {{- $tlsOptionsAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametertlsoptions ) }}
    {{- if $tlsOptionsAdditionnalInfos }}
{{ toYaml $tlsOptionsAdditionnalInfos | indent 2 }}
    {{- /* END IF tlsoptionsAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE tlsoptions */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
