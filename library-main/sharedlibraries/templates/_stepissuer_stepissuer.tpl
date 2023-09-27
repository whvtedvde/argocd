{{/* library template for stepissuer stepissuer definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################

# -- (dict) stepIssuer
# @default -- see subconfig
# DOC: [stepIssuer](https://github.com/smallstep/step-issuer)
stepIssuer:

  # -- Create stepissuer stepissuer
  # @default -- see subconfig
  # DOC : [stepissuer](https://github.com/smallstep/step-issuer)
  ## HELPER stepIssuer AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,type, provisioner, url
  stepIssuer:
    -
      # -- (string)[REQ] name
      name: stepissuer-stepissuer-test
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

      # -- (dict)[REQ] provisioner
      provisioner:

         # -- (string)[REQ] kid
        kid: nIIAX2GMQItuEvOPzFddIjyTmHoD0KwjWgMpmujvsqM

        # -- (string)[REQ] name
        name: step-issuer

        # -- (dict)[REQ] passwordRef
        ## HELPER passwordRef AdditionnalInfos
        ## write as YAML (without formating or validation) everything except:
        ## name,kind
        passwordRef:

          # -- (dict)[REQ] name
          name: secret-sync-vault-stepca

          # -- (dict)[REQ] namespace
          kind:  step-issuer

          # -- (dict)[OPT] key
          key: step-issuer

      # -- (string)[REQ] url
      url: 'https://pki-step-certificates.outils.svc.cluster.local'

      # -- (string)[OPT] caBundle
      caBundle: >-
        LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURnVENDQW1tZ0F3SUJBZ0lJSXNpTHZiSURWRmt3RFFZSktvWklodmNOQVFFTEJRQXdUakVVTUJJR0ExVUUKQXd3TFQwRkNJRkp2YjNRZ1EwRXhLVEFuQmdOVkJBb01JRTl5WVc1blpTQkJjSEJzYVdOaGRHbHZibk1nWm05eQpJRUoxYzJsdVpYTnpNUXN3Q1FZRFZRUUdFd0pHVWpBZUZ3MHhOVEV3TURneE1qVTJOVGRhRncwek5URXdNRE14Ck1qVTJOVGRhTUU0eEZEQVNCZ05WQkFNTUMwOUJRaUJTYjI5MElFTkJNU2t3SndZRFZRUUtEQ0JQY21GdVoyVWcKUVhCd2JHbGpZWFJwYjI1eklHWnZjaUJDZFhOcGJtVnpjekVMTUFrR0ExVUVCaE1DUmxJd2dnRWlNQTBHQ1NxRwpTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDam5MYUk1NVFOZHhIUENOUVV1VEtweUZTQVpldktZN0tkCk51ZXVMaGVWVmM1RWZtVUppNXN6ZmJDZGFjc1RvMUtpT3VhRVFlR0paUnRPLythcVhoRHB4L1Q4NzM3VWQ4R0oKWTJqeTBrdHcva2liTEF6N2V3K0lsNVFLL1dLSXYzRkRCT0NCa2U0cnVtTUV5Q2ZxanFFWVkvRFkrVlRta0F0MworclNQSXU5R2I2YkxUV0lpd1ZkemVZZ3dvbHNteUdPb21rZU9DSU9WV1YwQnUwL2Z2cy9UOGNDQnJ6cGcvdXB4CnJnbmdyQk5wMGxLZGlOdStkbDNRSy8xdHptL0EyTCtwM3BVNzlJWmJtUE9IRGhodWFiMlB1SG8wbUJMZEFSYmgKUXdHVVo1N1BlbXcvV1NYM2kxclpXMWlKQW1lZ0NaZDJTcHdOc2hMLzdKVGM5VnEvSjVGTkFnTUJBQUdqWXpCaApNQjBHQTFVZERnUVdCQlNUUmg3ckprT1JSMDQvdHFvMXlrRTlJVVBON2pBUEJnTlZIUk1CQWY4RUJUQURBUUgvCk1COEdBMVVkSXdRWU1CYUFGSk5HSHVzbVE1RkhUaisycWpYS1FUMGhRODN1TUE0R0ExVWREd0VCL3dRRUF3SUIKaGpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUdCbjNyeEJ0clNwbUlqdjhldHVlUTN6emR5MS9RMU9UdFY3dApyV1RxVGtiM0Y0eVlzQTNUS0dIUXpkd0hObDAwWWFnMllOR09UenJNRUNacDhNVi9IYW5iRCtIZUs2OHFsUk1aCmRCZWtIZHQxdFBMcEpJODFkcm1zbkRESW9naVEyeGd6eXlZWW13MDNtSkNHTXpIdmEwYWhKWGpGUGErZE5HZWwKWno3WHBrMGJ4UCt1V0t6bXl4Q2MwQmdYOHR1VTdHS1lFSjVyNDZSd3Z5b05Rek8vSng3SXMzVGlSbjZ2aU9Tdwp6TEt5RWRpMXpZUHlJSWlRNDdaNUhVMXFDNjY2dTRBYU95QmQwTUErOWlyOUt4QmVIRlZ6U0xxM0sxUi9hUEJJCkJJS2xsbHFDTW5jakhHQjIzNXg4S0VQZ2RiMSt5c0MwRVY4WlZtbkQxT3YzYUJxcnlRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ==

*/}}
{{- define "sharedlibraries.stepissuer_stepissuer" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.stepIssuer  */}}
  {{- if and ( not $.Values.stepIssuer ) }}
    {{- fail "stepissuer_stepissuer template loaded without stepissuer object" }}
  {{- end }}
  {{/* CHECK $.Values.stepIssuer.stepIssuer  */}}
  {{- if and (not $.Values.stepIssuer) }}
    {{- fail "stepissuer_stepissuer template loaded without stepIssuer.stepIssuer object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "provisioner" "url" ) }}
  {{- range $stepIssuer := $.Values.stepIssuer.stepIssuer }}
    {{/* DEBUG include "sharedlibraries.dump" $stepIssuer */}}
    {{/*
    ######################################
    Validation Mandatory Variables stepIssuer
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $stepIssuer.name
    ######################################
    */}}
    {{- if not $stepIssuer.name }}
      {{- fail "No name set inside stepIssuer.stepIssuer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $stepIssuer.namespace
    ######################################
    */}}
    {{- if not $stepIssuer.namespace }}
      {{- fail "No namespace set inside stepIssuer.stepIssuer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $stepIssuer.additionalLabels
    ######################################
    */}}
    {{- if and ( $stepIssuer.additionalLabels ) ( not (kindIs "map" $stepIssuer.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside stepIssuer.stepIssuer object but type is :%s" ( kindOf $stepIssuer.additionalLabels )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $stepIssuer.additionalAnnotations
    ######################################
    */}}
    {{- if and ($stepIssuer.additionalAnnotations) (not (kindIs "map" $stepIssuer.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside stepIssuer.stepIssuer object but type is :%s" ( kindOf $stepIssuer.additionalAnnotations )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK provisionner $stepIssuer.url
    ######################################
    */}}
    {{- if not $stepIssuer.url  }}
      {{- fail "No url  set inside stepIssuer.stepIssuer object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK provisionner $stepIssuer.provisioner
    ######################################
    */}}
    {{- $parameterCheckDictStepIssuerStepIssuer := dict }}
    {{- $parameterCheckDictStepIssuerStepIssuerMandatoryKeys := ( list "kid" "name" "passwordRef" ) }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuer "fromDict" $stepIssuer }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuer "masterKey" "provisioner" }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuer "baseKey" "stepIssuer" }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuer "mandatoryKeys" $parameterCheckDictStepIssuerStepIssuerMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictStepIssuerStepIssuer }}
    {{/*
    ######################################
    CHECK provisionner $stepIssuer.provisioner.passwordRef
    ######################################
    */}}
    {{- $parameterCheckDictStepIssuerStepIssuerPasswordRef := dict }}
    {{- $parameterCheckDictStepIssuerStepIssuerPasswordRefMandatoryKeys := ( list "name" ) }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuerPasswordRef "fromDict" $stepIssuer.provisioner }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuerPasswordRef "masterKey" "passwordRef" }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuerPasswordRef "baseKey" "stepIssuer.provisioner" }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuerPasswordRef "mandatoryKeys" $parameterCheckDictStepIssuerStepIssuerPasswordRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictStepIssuerStepIssuerPasswordRef }}
---
apiVersion: certmanager.step.sm/v1beta1
kind: StepIssuer
metadata:
  name: {{ $stepIssuer.name }}
  namespace: {{ $stepIssuer.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $stepIssuer.additionalLabels }}
{{ toYaml $stepIssuer.additionalLabels | indent 4 }}
    {{/* END IF stepissuer.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $stepIssuer.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $stepIssuer.additionalAnnotations }}
{{ toYaml $stepIssuer.additionalAnnotations | indent 4 }}
    {{/* END IF stepIssuer.additionalAnnotations */}}
    {{- end }}
spec:
  provisioner:
    kid: {{ $stepIssuer.provisioner.kid }}
    name: {{ $stepIssuer.provisioner.name }}
    passwordRef:
      name: {{ $stepIssuer.provisioner.passwordRef.name }}
    {{- $parameterstepissuerpasswordRef := dict }}
    {{- $avoidKeysstepissuerpasswordRef := ( list "name" ) }}
    {{- $_ := set $parameterstepissuerpasswordRef "fromDict" $stepIssuer.provisioner.passwordRef }}
    {{- $_ := set $parameterstepissuerpasswordRef "avoidList" $avoidKeysstepissuerpasswordRef }}
    {{- $stepIssuerpasswordRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterstepissuerpasswordRef ) }}
    {{- if $stepIssuerpasswordRefAdditionnalInfos }}
{{ toYaml $stepIssuerpasswordRefAdditionnalInfos | indent 6 }}
    {{/* END IF stepissuerpasswordRefAdditionnalInfos */}}
    {{- end }}
    {{- $parameterstepissuer := dict }}
    {{- $_ := set $parameterstepissuer "fromDict" $stepIssuer }}
    {{- $_ := set $parameterstepissuer "avoidList" $avoidKeys }}
    {{- $stepIssuerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterstepissuer ) }}
    {{- if $stepIssuerAdditionnalInfos }}
{{ toYaml $stepIssuerAdditionnalInfos | indent 2 }}
    {{/* END IF stepissuerAdditionnalInfos */}}
    {{- end }}
...
  {{/* END RANGE stepIssuer */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
