{{/* library template for certmanager certificate definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################

# -- (dict) certManager definition
# @default -- see subconfig
### This comment will be only visible in yaml file
certManager:
  ### KEEP COMMENT only in yaml file
  # -- Create certmanager certificate
  # DOC : [cert usage](https://cert-manager.io/docs/usage/certificate/)
  # DOC : [cert concept](https://cert-manager.io/docs/concepts/certificate/)
  ## HELPER certificate AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, secretName, issuerRef, template
  ### This comment will be only visible in yaml file
  certificate:
    -
      # -- (string)[REQ] name
      name: certmanager-certificate
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

      # -- (string)[REQ] secretName
      secretName: secret-certmanager-certificate

      # -- (dict)[REQ] issuerRef
      ## HELPER issuerRef AdditionnalInfos
      ## write as YAML (without formating or validation) everything except:
      ## name
      issuerRef:
        # -- (string)[REQ] name
        name: step-clusterissuer
        # -- (string)[OPT] group
        group: certmanager.step.sm
        # -- (string)[OPT] kind
        kind: StepClusterIssuer

      # -- (string)[OPT] commonName
      commonName: '*.test.paiprp.620nm.net'
      # -- (list)[OPT] dnsNames
      dnsNames:
        - test.paiprp.620nm.net
        - '*.test.paiprp.620nm.net'
      # -- (string)[OPT] duration
      duration: 48h0m0s
      # -- (list)[OPT] ipAddresses
      ipAddresses:
        - 10.222.1.20
      # -- (dict)[OPT] privateKey
      privateKey:
        # -- (string)[OPT] algorithm
        algorithm: RSA
        # -- (string)[OPT] rotationPolicy
        rotationPolicy: Always
        # -- (int)[OPT] size
        size: 4096
      # -- (string)[OPT] commonName
      renewBefore: 8h0m0s


*/}}
{{- define "sharedlibraries.certmanager_certificate" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.certManager  */}}
  {{- if and ( not $.Values.certManager ) }}
    {{- fail "certmanager_certificate template loaded without certmanager object" }}
  {{- end }}
  {{/* CHECK $.Values.certManager.certificate  */}}
  {{- if and (not $.Values.certManager) }}
    {{- fail "certmanager_certificate template loaded without certmanager.certificate object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "secretName" "issuerRef" ) }}
  {{- range $certificate := $.Values.certManager.certificate }}
    {{/* DEBUG include "sharedlibraries.dump" $certificate */}}
    {{/*
    ######################################
    Validation Mandatory Variables certificate
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $certificate.name
    ######################################
    */}}
    {{- if not $certificate.name }}
      {{- fail "No name set inside certmanager.certificate object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $certificate.namespace
    ######################################
    */}}
    {{- if not $certificate.namespace }}
      {{- fail "No namespace set inside certmanager.certificate object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $certificate.additionalLabels
    ######################################
    */}}
    {{- if and ( $certificate.additionalLabels ) ( not (kindIs "map" $certificate.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside certmanager.certificate object but type is :%s" ( kindOf $certificate.additionalLabels )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $certificate.additionalAnnotations
    ######################################
    */}}
    {{- if and ($certificate.additionalAnnotations) (not (kindIs "map" $certificate.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside certmanager.certificate object but type is :%s" ( kindOf $certificate.additionalAnnotations )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK secretName $certificate.secretName
    ######################################
    */}}
    {{- if not $certificate.secretName }}
      {{- fail "No secretName set inside certmanager.certificate object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK issuerRef $certificate.issuerRef
    ######################################
    */}}
    {{- $parameterCheckDictCertificateIssuerRef := dict }}
    {{- $parameterCheckDictCertificateIssuerRefMandatoryKeys := ( list "name" ) }}
    {{- $_ := set $parameterCheckDictCertificateIssuerRef "fromDict" $certificate }}
    {{- $_ := set $parameterCheckDictCertificateIssuerRef "masterKey" "issuerRef" }}
    {{- $_ := set $parameterCheckDictCertificateIssuerRef "baseKey" "certificate" }}
    {{- $_ := set $parameterCheckDictCertificateIssuerRef "mandatoryKeys" $parameterCheckDictCertificateIssuerRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictCertificateIssuerRef }}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ $certificate.name }}
  namespace: {{ $certificate.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $certificate.additionalLabels }}
{{ toYaml $certificate.additionalLabels | indent 4 }}
    {{/* END IF certificate.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $certificate.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $certificate.additionalAnnotations }}
{{ toYaml $certificate.additionalAnnotations | indent 4 }}
    {{/* END IF certificate.additionalAnnotations */}}
    {{- end }}
spec:
  secretName: {{ $certificate.secretName }}
  issuerRef:
    name: {{ $certificate.issuerRef.name }}
    {{- $parametercertificateissuerRef := dict }}
    {{- $avoidKeyscertificateissuerRef := ( list "name" ) }}
    {{- $_ := set $parametercertificateissuerRef "fromDict" $certificate.issuerRef }}
    {{- $_ := set $parametercertificateissuerRef "avoidList" $avoidKeyscertificateissuerRef }}
    {{- $certificateissuerRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametercertificateissuerRef ) }}
    {{- if $certificateissuerRefAdditionnalInfos }}
{{ toYaml $certificateissuerRefAdditionnalInfos | indent 4 }}
    {{/* END IF certificateissuerRefAdditionnalInfos */}}
    {{- end }}
    {{- $parametercertificate := dict }}
    {{- $_ := set $parametercertificate "fromDict" $certificate }}
    {{- $_ := set $parametercertificate "avoidList" $avoidKeys }}
    {{- $certificateAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametercertificate ) }}
    {{- if $certificateAdditionnalInfos }}
{{ toYaml $certificateAdditionnalInfos | indent 2 }}
    {{/* END IF certificateAdditionnalInfos */}}
    {{- end }}
...
  {{/* END RANGE certificate */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
