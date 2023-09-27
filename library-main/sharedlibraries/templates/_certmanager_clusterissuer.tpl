{{/* library template for certmanager clusterissuer definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################

# -- (dict) certManager definition
# @default -- see subconfig
### This comment will be only visible in yaml file
certManager:

  # -- Create certmanager clusterissuer
  # @default -- see subconfig
  # DOC : [clusterissuer](https://cert-manager.io/docs/configuration/)
  # DOC : [clusterissuer concepts](https://cert-manager.io/docs/concepts/clusterissuer/)
  ## HELPER clusterIssuer AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, additionalLabels, additionalAnnotations, syncWave
  clusterIssuer:

    -
      # -- (string)[REQ] name
      name: certmanager-clusterissuer-letsencrypt-stagging

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
{{- define "sharedlibraries.certmanager_clusterissuer" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.certManager  */}}
  {{- if and ( not $.Values.certManager ) }}
    {{- fail "certmanager_clusterissuer template loaded without certmanager object" }}
  {{- end }}
  {{/* CHECK $.Values.certManager.clusterissuer  */}}
  {{- if and (not $.Values.certManager) }}
    {{- fail "certmanager_clusterissuer template loaded without certmanager.clusterissuer object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "additionalLabels" "additionalAnnotations" "syncWave" ) }}
  {{- range $clusterIssuer := $.Values.certManager.clusterIssuer }}
    {{/* DEBUG include "sharedlibraries.dump" $clusterIssuer */}}
    {{/*
    ######################################
    Validation Mandatory Variables clusterissuer
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $clusterIssuer.name
    ######################################
    */}}
    {{- if not $clusterIssuer.name }}
      {{- fail "No name set inside certmanager.clusterissuer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $clusterIssuer.additionalLabels
    ######################################
    */}}
    {{- if and ( $clusterIssuer.additionalLabels ) ( not (kindIs "map" $clusterIssuer.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside certmanager.clusterissuer object but type is :%s" ( kindOf $clusterIssuer.additionalLabels )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $clusterIssuer.additionalAnnotations
    ######################################
    */}}
    {{- if and ($clusterIssuer.additionalAnnotations) (not (kindIs "map" $clusterIssuer.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside certmanager.clusterissuer object but type is :%s" ( kindOf $clusterIssuer.additionalAnnotations )) }}
    {{- end }}
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: {{ $clusterIssuer.name }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $clusterIssuer.additionalLabels }}
{{ toYaml $clusterIssuer.additionalLabels | indent 4 }}
    {{/* END IF clusterissuer.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $clusterIssuer.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $clusterIssuer.additionalAnnotations }}
{{ toYaml $clusterIssuer.additionalAnnotations | indent 4 }}
    {{/* END IF clusterissuer.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameterclusterissuer := dict }}
    {{- $_ := set $parameterclusterissuer "fromDict" $clusterIssuer }}
    {{- $_ := set $parameterclusterissuer "avoidList" $avoidKeys }}
    {{- $clusterIssuerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterclusterissuer ) }}
    {{- if $clusterIssuerAdditionnalInfos }}
{{ toYaml $clusterIssuerAdditionnalInfos | indent 2 }}
    {{/* END IF clusterissuerAdditionnalInfos */}}
    {{- end }}
...
  {{/* END RANGE clusterissuer */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
