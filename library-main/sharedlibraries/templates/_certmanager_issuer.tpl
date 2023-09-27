{{/* library template for certmanager issuer definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################

# -- (dict) certManager definition
# @default -- see subconfig
### This comment will be only visible in yaml file
certManager:

  # -- Create certmanager issuer
  # @default -- see subconfig
  # DOC : [issuer](https://cert-manager.io/docs/configuration/)
  # DOC : [issuer concept](https://cert-manager.io/docs/concepts/issuer/)
  ## HELPER issuer AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  issuer:
    -
      # -- (string)[REQ] name
      name: certmanager-issuer-letsencrypt-stagging
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

      # -- (dict)[OPT] acme
      # @default -- see subconfig
      acme:
        # -- (string)[OPT] email
        ## You must replace this email address with your own.
        ## Let's Encrypt will use this to contact you about expiring
        ## certificates, and issues related to your account.
        email: user@example.com
        # -- (string)[OPT] server
        server: https://acme-staging-v02.api.letsencrypt.org/directory
        # -- (dict)[OPT] privateKeySecretRef
        privateKeySecretRef:
          # -- (string)[OPT] name
          ## Secret resource that will be used to store the account's private key.
          name: secret-certmanager-issuer-letsencrypt-stagging
        # -- (list)[OPT] solvers
        ## Add a single challenge solver, HTTP01 using nginx
        solvers:
        - http01:
            ingress:
              class: traefik



*/}}
{{- define "sharedlibraries.certManager_issuer" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.certManager  */}}
  {{- if and ( not $.Values.certManager ) }}
    {{- fail "certmanager_issuer template loaded without certmanager object" }}
  {{- end }}
  {{/* CHECK $.Values.certManager.issuer  */}}
  {{- if and (not $.Values.certManager) }}
    {{- fail "certmanager_issuer template loaded without certmanager.issuer object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}
  {{- range $issuer := $.Values.certManager.issuer }}
    {{/* DEBUG include "sharedlibraries.dump" $issuer */}}
    {{/*
    ######################################
    Validation Mandatory Variables issuer
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $issuer.name
    ######################################
    */}}
    {{- if not $issuer.name }}
      {{- fail "No name set inside certmanager.issuer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $issuer.namespace
    ######################################
    */}}
    {{- if not $issuer.namespace }}
      {{- fail "No namespace set inside certmanager.issuer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $issuer.additionalLabels
    ######################################
    */}}
    {{- if and ( $issuer.additionalLabels ) ( not (kindIs "map" $issuer.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside certmanager.issuer object but type is :%s" ( kindOf $issuer.additionalLabels )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $issuer.additionalAnnotations
    ######################################
    */}}
    {{- if and ($issuer.additionalAnnotations) (not (kindIs "map" $issuer.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside certmanager.issuer object but type is :%s" ( kindOf $issuer.additionalAnnotations )) }}
    {{- end }}
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: {{ $issuer.name }}
  namespace: {{ $issuer.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $issuer.additionalLabels }}
{{ toYaml $issuer.additionalLabels | indent 4 }}
    {{/* END IF issuer.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $issuer.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $issuer.additionalAnnotations }}
{{ toYaml $issuer.additionalAnnotations | indent 4 }}
    {{/* END IF issuer.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameterissuer := dict }}
    {{- $_ := set $parameterissuer "fromDict" $issuer }}
    {{- $_ := set $parameterissuer "avoidList" $avoidKeys }}
    {{- $issuerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterissuer ) }}
    {{- if $issuerAdditionnalInfos }}
{{ toYaml $issuerAdditionnalInfos | indent 2 }}
    {{/* END IF issuerAdditionnalInfos */}}
    {{- end }}
...
  {{/* END RANGE issuer */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
