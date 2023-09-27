{{- /* library template for mariaDb user definition */}}
{{- /*
BEGVAL
mariaDb:
  # -- Create mariaDb user
  # @default -- see subconfig
  ## HELPER user AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,mariaDbRef,passwordSecretKeyRef
  user:
    -
      # -- (string)[REQ] name
      name: testdb
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
      syncWave: 02

      # -- (dict)[REQ] mariaDbRef
      ## HELPER mariaDbRef AdditionnalInfos
      ## write as YAML (without formating or validation) everything except:
      ## name
      mariaDbRef:
        name: mariadb-outils

      # -- (dict)[REQ] passwordSecretKeyRef
      ## HELPER passwordSecretKeyRef AdditionnalInfos
      ## write as YAML (without formating or validation) everything except:
      ## key
      ## name
      passwordSecretKeyRef:
        name: secret-mariadb-outils
        key: testdb-password

      # -- (int)[OPT] maxUserConnections
      maxUserConnections: 20
ENDVAL
*/}}
{{- define "sharedlibraries.mariadb_user" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and (not $.Values.mariaDb) }}
    {{- fail "mariadb_user template loaded without mariaDb object" }}
  {{- end }}

  {{- if and (not $.Values.mariaDb.user ) }}
    {{- fail "mariadb_user template loaded without mariaDb.user object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "mariaDbRef" "passwordSecretKeyRef" ) }}

  {{- /*
  #################################
  LOOP all user instance
  #################################
  */}}
  {{- range $user := $.Values.mariaDb.user }}
    {{- /* DEBUG include "sharedlibraries.dump" $user */}}

    {{- /*
    #################################
    CHECK mandatory user values
    #################################
    */}}

    {{- /* CHECK user.name */}}
    {{- if not $user.name }}
      {{- fail "No name set inside mariaDb.user object" }}
    {{- end }}

    {{- /* CHECK user.name */}}
    {{- if not $user.namespace }}
      {{- fail "No namespace set inside mariaDb.user object" }}
    {{- end }}

    {{- /* CHECK user.mariaDbRef */}}
    {{- if not $user.mariaDbRef }}
      {{- fail "No mariaDbRef set inside mariaDb.user object" }}
    {{- end }}
    {{- if and ( $user.mariaDbRef  ) ( not ( kindIs "map" $user.mariaDbRef  ) ) }}
      {{- fail ( printf "mariaDbRef is not a DICT inside mariaDb.user object but type is :%s" ( kindOf $user.mariaDbRef ) ) }}
    {{- end }}

    {{- /* CHECK user.passwordSecretKeyRef */}}
    {{- if not $user.passwordSecretKeyRef }}
      {{- fail "No passwordSecretKeyRef set inside mariaDb.user object" }}
    {{- end }}
    {{- if and ( $user.passwordSecretKeyRef  ) ( not ( kindIs "map" $user.passwordSecretKeyRef  ) ) }}
      {{- fail ( printf "passwordSecretKeyRef is not a DICT inside mariaDb.user object but type is :%s" ( kindOf $user.passwordSecretKeyRef ) ) }}
    {{- end }}

    {{- /* CHECK user.additionalLabels */}}
    {{- if and ( $user.additionalLabels ) ( not ( kindIs "map" $user.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside mariaDb.user object but type is :%s" ( kindOf $user.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK user.additionalAnnotations */}}
    {{- if and ( $user.additionalAnnotations ) ( not ( kindIs "map" $user.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside mariaDb.user object but type is :%s" ( kindOf $user.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictMariaDbRef */}}
    {{- $parameterCheckDictMariaDbRef := dict }}
    {{- $parameterCheckDictMariaDbRefMandatoryKeys := ( list "name" ) }}
    {{- $_ := set $parameterCheckDictMariaDbRef "fromDict" $user }}
    {{- $_ := set $parameterCheckDictMariaDbRef "masterKey" "mariaDbRef" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "baseKey" "user" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "mandatoryKeys" $parameterCheckDictMariaDbRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictMariaDbRef }}

    {{- /* CHECK parameterCheckDictPasswordSecretKeyRef */}}
    {{- $parameterCheckDictPasswordSecretKeyRef := dict }}
    {{- $parameterCheckDictPasswordSecretKeyRefMandatoryKeys := ( list "name" "key" ) }}
    {{- $_ := set $parameterCheckDictPasswordSecretKeyRef "fromDict" $user }}
    {{- $_ := set $parameterCheckDictPasswordSecretKeyRef "masterKey" "passwordSecretKeyRef" }}
    {{- $_ := set $parameterCheckDictPasswordSecretKeyRef "baseKey" "user" }}
    {{- $_ := set $parameterCheckDictPasswordSecretKeyRef "mandatoryKeys" $parameterCheckDictPasswordSecretKeyRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictPasswordSecretKeyRef }}


{{- /* TEMPLATE */}}
---
apiVersion: mariadb.mmontes.io/v1alpha1
kind: User
metadata:
  name: {{ $user.name }}
  namespace: {{ $user.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $user.additionalLabels }}
{{ toYaml $user.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "02" $user.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $user.additionalAnnotations }}
{{ toYaml $user.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  mariaDbRef:
    name: {{ $user.mariaDbRef.name }}
    {{- $parameterMariaDbRef := dict }}
    {{- $avoidKeysMariaDbRef := ( list "name" ) }}
    {{- $_ := set $parameterMariaDbRef "fromDict" $user.mariaDbRef }}
    {{- $_ := set $parameterMariaDbRef "avoidList" $avoidKeysMariaDbRef }}
    {{- $mariaDbRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterMariaDbRef ) }}
    {{- if $mariaDbRefAdditionnalInfos }}
{{ toYaml $mariaDbRefAdditionnalInfos | indent 4 }}
    {{- /* END IF mariaDbRefAdditionnalInfos */}}
    {{- end }}
  passwordSecretKeyRef:
    key: {{ $user.passwordSecretKeyRef.key }}
    name: {{ $user.passwordSecretKeyRef.name }}
    {{- $parameterPasswordSecretKeyRef := dict }}
    {{- $avoidKeysPasswordSecretKeyRef := ( list "name" "key" ) }}
    {{- $_ := set $parameterPasswordSecretKeyRef "fromDict" $user.passwordSecretKeyRef }}
    {{- $_ := set $parameterPasswordSecretKeyRef "avoidList" $avoidKeysPasswordSecretKeyRef }}
    {{- $passwordSecretKeyRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterPasswordSecretKeyRef ) }}
    {{- if $passwordSecretKeyRefAdditionnalInfos }}
{{ toYaml $passwordSecretKeyRefAdditionnalInfos | indent 4 }}
    {{- /* END IF passwordSecretKeyRefAdditionnalInfos */}}
    {{- end }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $user }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $userAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $userAdditionnalInfos }}
{{ toYaml $userAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
