{{- /* library template for stepissuer stepClusterIssuer definition */}}
{{- /*
BEGVAL
# -- (dict) stepIssuer
# @default -- see subconfig
# DOC: [stepIssuer](https://github.com/smallstep/step-issuer)
stepIssuer:
  # -- Create stepissuer stepClusterIssuer
  # @default -- see subconfig
  # DOC : [stepClusterIssuer](https://github.com/smallstep/step-issuer)
  ## HELPER stepClusterIssuer AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,type, provisioner, url
  stepClusterIssuer:
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

         # -- (string)[REQ] kid OR kidExistingSecrets
        kid: xxxxxxxxxxxxxxxxxxxxxxx

        # -- (string)[REQ] kid OR kidExistingSecrets
        kidExistingSecrets:
          name: secret-sync-vault-stepca-stepclusterissuer-kid
          namespace: outils
          key: thiskey

        # -- (string)[REQ] name
        name: step-issuer

        # -- (dict)[REQ] passwordRef
        ## HELPER passwordRef AdditionnalInfos
        ## write as YAML (without formating or validation) everything except:
        ## name,namespace
        passwordRef:

          # -- (dict)[REQ] name
          name: secret-sync-vault-stepca

          # -- (dict)[REQ] namespace
          namespace:  step-issuer

          # -- (dict)[OPT] key
          key: step-issuer

      # -- (string)[REQ] url
      url: 'https://pki-step-certificates.outils.svc.cluster.local'

      # -- (string)[OPT] caBundle
      caBundle: >-
        LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURnVENDQW1tZ0F3SUJBZ0lJSXNpTHZiSURWRmt3RFFZSktvWklodmNOQVFFTEJRQXdUakVVTUJJR0ExVUUKQXd3TFQwRkNJRkp2YjNRZ1EwRXhLVEFuQmdOVkJBb01JRTl5WVc1blpTQkJjSEJzYVdOaGRHbHZibk1nWm05eQpJRUoxYzJsdVpYTnpNUXN3Q1FZRFZRUUdFd0pHVWpBZUZ3MHhOVEV3TURneE1qVTJOVGRhRncwek5URXdNRE14Ck1qVTJOVGRhTUU0eEZEQVNCZ05WQkFNTUMwOUJRaUJTYjI5MElFTkJNU2t3SndZRFZRUUtEQ0JQY21GdVoyVWcKUVhCd2JHbGpZWFJwYjI1eklHWnZjaUJDZFhOcGJtVnpjekVMTUFrR0ExVUVCaE1DUmxJd2dnRWlNQTBHQ1NxRwpTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDam5MYUk1NVFOZHhIUENOUVV1VEtweUZTQVpldktZN0tkCk51ZXVMaGVWVmM1RWZtVUppNXN6ZmJDZGFjc1RvMUtpT3VhRVFlR0paUnRPLythcVhoRHB4L1Q4NzM3VWQ4R0oKWTJqeTBrdHcva2liTEF6N2V3K0lsNVFLL1dLSXYzRkRCT0NCa2U0cnVtTUV5Q2ZxanFFWVkvRFkrVlRta0F0MworclNQSXU5R2I2YkxUV0lpd1ZkemVZZ3dvbHNteUdPb21rZU9DSU9WV1YwQnUwL2Z2cy9UOGNDQnJ6cGcvdXB4CnJnbmdyQk5wMGxLZGlOdStkbDNRSy8xdHptL0EyTCtwM3BVNzlJWmJtUE9IRGhodWFiMlB1SG8wbUJMZEFSYmgKUXdHVVo1N1BlbXcvV1NYM2kxclpXMWlKQW1lZ0NaZDJTcHdOc2hMLzdKVGM5VnEvSjVGTkFnTUJBQUdqWXpCaApNQjBHQTFVZERnUVdCQlNUUmg3ckprT1JSMDQvdHFvMXlrRTlJVVBON2pBUEJnTlZIUk1CQWY4RUJUQURBUUgvCk1COEdBMVVkSXdRWU1CYUFGSk5HSHVzbVE1RkhUaisycWpYS1FUMGhRODN1TUE0R0ExVWREd0VCL3dRRUF3SUIKaGpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUdCbjNyeEJ0clNwbUlqdjhldHVlUTN6emR5MS9RMU9UdFY3dApyV1RxVGtiM0Y0eVlzQTNUS0dIUXpkd0hObDAwWWFnMllOR09UenJNRUNacDhNVi9IYW5iRCtIZUs2OHFsUk1aCmRCZWtIZHQxdFBMcEpJODFkcm1zbkRESW9naVEyeGd6eXlZWW13MDNtSkNHTXpIdmEwYWhKWGpGUGErZE5HZWwKWno3WHBrMGJ4UCt1V0t6bXl4Q2MwQmdYOHR1VTdHS1lFSjVyNDZSd3Z5b05Rek8vSng3SXMzVGlSbjZ2aU9Tdwp6TEt5RWRpMXpZUHlJSWlRNDdaNUhVMXFDNjY2dTRBYU95QmQwTUErOWlyOUt4QmVIRlZ6U0xxM0sxUi9hUEJJCkJJS2xsbHFDTW5jakhHQjIzNXg4S0VQZ2RiMSt5c0MwRVY4WlZtbkQxT3YzYUJxcnlRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ==

ENDVAL
*/}}
{{- define "sharedlibraries.stepissuer_stepclusterissuer" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.stepIssuer ) }}
    {{- fail "stepissuer_stepclusterissuer template loaded without stepIssuer object" }}
  {{- end }}

  {{- if and (not $.Values.stepIssuer.stepClusterIssuer) }}
    {{- fail "stepissuer_stepclusterissuer template loaded without stepIssuer.stepClusterIssuer object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "additionalLabels" "additionalAnnotations" "syncWave" "provisioner" "url" ) }}

  {{- /*
  #################################
  LOOP all stepClusterIssuer instance
  #################################
  */}}
  {{- range $stepClusterIssuer := $.Values.stepIssuer.stepClusterIssuer }}
    {{- /* DEBUG include "sharedlibraries.dump" $stepClusterIssuer */}}

    {{- /*
    #################################
    CHECK mandatory stepClusterIssuer values
    #################################
    */}}

    {{- /* CHECK stepClusterIssuer.name */}}
    {{- if not $stepClusterIssuer.name }}
      {{- fail "No name set inside stepIssuer.stepClusterIssuer object" }}
    {{- end }}

    {{- /* CHECK stepClusterIssuer.name */}}
    {{- if and ( $stepClusterIssuer.additionalLabels ) ( not (kindIs "map" $stepClusterIssuer.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside stepIssuer.stepClusterIssuer object but type is :%s" ( kindOf $stepClusterIssuer.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK stepClusterIssuer.name */}}
    {{- if and ($stepClusterIssuer.additionalAnnotations) (not (kindIs "map" $stepClusterIssuer.additionalAnnotations ) ) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside stepIssuer.stepClusterIssuer object but type is :%s" ( kindOf $stepClusterIssuer.additionalAnnotations  ) ) }}
    {{- end }}

    {{- /* CHECK stepClusterIssuer.name */}}
    {{- if not $stepClusterIssuer.url  }}
      {{- fail "No url  set inside stepIssuer.stepClusterIssuerobject" }}
    {{- end }}

    {{- /* CHECK stepClusterIssuer.name */}}
    {{- $parameterCheckDictStepIssuerStepIssuer := dict }}
    {{- $parameterCheckDictStepIssuerStepIssuerMandatoryKeys := ( list "name" "passwordRef" ) }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuer "fromDict" $stepClusterIssuer }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuer "masterKey" "provisioner" }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuer "baseKey" "stepClusterIssuer" }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuer "mandatoryKeys" $parameterCheckDictStepIssuerStepIssuerMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictStepIssuerStepIssuer }}


    {{- /* CHECK stepClusterIssuer.name */}}
    {{- $parameterCheckDictStepIssuerStepIssuerPasswordRef := dict }}
    {{- $parameterCheckDictStepIssuerStepIssuerPasswordRefMandatoryKeys := ( list "name" "namespace" ) }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuerPasswordRef "fromDict" $stepClusterIssuer.provisioner }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuerPasswordRef "masterKey" "passwordRef" }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuerPasswordRef "baseKey" "stepClusterIssuer.provisioner" }}
    {{- $_ := set $parameterCheckDictStepIssuerStepIssuerPasswordRef "mandatoryKeys" $parameterCheckDictStepIssuerStepIssuerPasswordRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictStepIssuerStepIssuerPasswordRef }}

{{- /* TEMPLATE */}}
---
apiVersion: certmanager.step.sm/v1beta1
kind: StepClusterIssuer
metadata:
  name: {{ $stepClusterIssuer.name }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $stepClusterIssuer.additionalLabels }}
{{ toYaml $stepClusterIssuer.additionalLabels | indent 4 }}
    {{- /* END IF stepissuer.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $stepClusterIssuer.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $stepClusterIssuer.additionalAnnotations }}
{{ toYaml $stepClusterIssuer.additionalAnnotations | indent 4 }}
    {{- /* END IF stepissuer.additionalAnnotations */}}
    {{- end }}
spec:
  url: {{ $stepClusterIssuer.url }}
  provisioner:
    {{- if and ( not $stepClusterIssuer.provisioner.kid  ) ( hasKey $stepClusterIssuer.provisioner "kidExistingSecrets" ) }}
    {{- $existingSecretKid := (lookup "v1" "Secret" $stepClusterIssuer.provisioner.kidExistingSecrets.namespace $stepClusterIssuer.provisioner.kidExistingSecrets.name ) }}
      {{- if not  $existingSecretKid }}
        {{- fail ( printf "Can't found secret %s in ns %s" $stepClusterIssuer.provisioner.kidExistingSecrets.name $stepClusterIssuer.provisioner.kidExistingSecrets.namespace ) }}
      {{- else }}
    kid: {{ (get $existingSecretKid.data $stepClusterIssuer.provisioner.kidExistingSecrets.key ) }}
      {{- /* END IF $existingSecretKid */}}
      {{- end }}
    {{- else }}
    kid: {{ $stepClusterIssuer.provisioner.kid }}
    {{- /* END IF $stepClusterIssuer.provisioner.kidExistingSecrets */}}
    {{- end }}
    name: {{ $stepClusterIssuer.provisioner.name }}
    passwordRef:
      name: {{ $stepClusterIssuer.provisioner.passwordRef.name }}
      namespace: {{ $stepClusterIssuer.provisioner.passwordRef.namespace }}
    {{- $parameterstepissuerpasswordRef := dict }}
    {{- $avoidKeysstepissuerpasswordRef := ( list "name" "namespace" ) }}
    {{- $_ := set $parameterstepissuerpasswordRef "fromDict" $stepClusterIssuer.provisioner.passwordRef }}
    {{- $_ := set $parameterstepissuerpasswordRef "avoidList" $avoidKeysstepissuerpasswordRef }}
    {{- $stepClusterIssuerpasswordRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterstepissuerpasswordRef ) }}
    {{- if $stepClusterIssuerpasswordRefAdditionnalInfos }}
{{ toYaml $stepClusterIssuerpasswordRefAdditionnalInfos | indent 6 }}
    {{- /* END IF stepissuerpasswordRefAdditionnalInfos */}}
    {{- end }}
    {{- $parameterstepissuer := dict }}
    {{- $_ := set $parameterstepissuer "fromDict" $stepClusterIssuer }}
    {{- $_ := set $parameterstepissuer "avoidList" $avoidKeys }}
    {{- $stepClusterIssuerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterstepissuer ) }}
    {{- if $stepClusterIssuerAdditionnalInfos }}
{{ toYaml $stepClusterIssuerAdditionnalInfos | indent 2 }}
    {{- /* END IF stepissuerAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE stepissuer */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
