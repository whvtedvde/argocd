{{- /* library template for mariaDb connection definition */}}
{{- /*
BEGVAL

mariaDb:
  # -- Create mariaDb connection
  # @default -- see subconfig
  ## HELPER connection AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations,syncWave,mariaDbRef,passwordSecretKeyRef,username
  connection:
    -
      # -- (string)[REQ] name
      name: con-testdb
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

      # -- (string)[REQ] username
      username: testdb

      # -- (string)[OPT] database
      database: testdb

      # -- (string)[OPT] secretName
      secretName: secret-mariadb-outils-testdb-con

      # -- (string)[OPT] serviceName
      serviceName: mariadb

      # -- (dict)[OPT] params
      params:
        parseTime: "true"

      # -- (dict)[OPT] secretTemplate
      secretTemplate:
        annotations:
          mariadb.mmontes.io/connection: outils-stepca
        labels:
          mariadb.mmontes.io/connection: outils-stepca
        # -- (string)[OPT] key
        ## Store secret as this format
        key: dsn

      # -- (dict)[OPT] healthCheck
      healthCheck:
        interval: 10s
        retryInterval: 3s
ENDVAL
*/}}
{{- define "sharedlibraries.mariadb_connection" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and (not $.Values.mariaDb) }}
    {{- fail "mariadb_connection template loaded without mariaDb object" }}
  {{- end }}

  {{- if and (not $.Values.mariaDb.connection ) }}
    {{- fail "mariadb_connection template loaded without mariaDb.connection object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "mariaDbRef" "passwordSecretKeyRef" "username" ) }}

  {{- /*
  #################################
  LOOP all connection instance
  #################################
  */}}

  {{- range $connection := $.Values.mariaDb.connection }}
    {{- /* DEBUG include "sharedlibraries.dump" $connection */}}

    {{- /*
    #################################
    CHECK mandatory connection values
    #################################
    */}}

    {{- /* CHECK connection.name */}}
    {{- if not $connection.name }}
      {{- fail "No name set inside mariaDb.connection object" }}
    {{- end }}

    {{- /* CHECK connection.namespace */}}
    {{- if not $connection.namespace }}
      {{- fail "No namespace set inside mariaDb.connection object" }}
    {{- end }}

    {{- /* CHECK connection.username */}}
    {{- if not $connection.username }}
      {{- fail "No username set inside mariaDb.connection object" }}
    {{- end }}

    {{- /* CHECK connection.mariaDbRef */}}
    {{- if not $connection.mariaDbRef }}
      {{- fail "No ipAddressPools set inside mariaDb.connection object" }}
    {{- end }}
    {{- if and ( $connection.mariaDbRef ) ( not ( kindIs "map" $connection.mariaDbRef  ) ) }}
      {{- fail ( printf "mariaDbRef is not a DICT inside mariaDb.connection object but type is :%s" ( kindOf $connection.mariaDbRef ) ) }}
    {{- end }}

    {{- /* CHECK connection.passwordSecretKeyRef */}}
    {{- if not $connection.passwordSecretKeyRef }}
      {{- fail "No passwordSecretKeyRef set inside mariaDb.connection object" }}
    {{- end }}
    {{- if and ( $connection.passwordSecretKeyRef ) ( not ( kindIs "map" $connection.passwordSecretKeyRef  ) ) }}
      {{- fail ( printf "passwordSecretKeyRef is not a DICT inside mariaDb.connection object but type is :%s" ( kindOf $connection.passwordSecretKeyRef ) ) }}
    {{- end }}

    {{- /* CHECK connection.additionalLabels */}}
    {{- if and ( $connection.additionalLabels ) ( not ( kindIs "map" $connection.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside mariaDb.connection object but type is :%s" ( kindOf $connection.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK connection.additionalAnnotations */}}
    {{- if and ( $connection.additionalAnnotations ) ( not ( kindIs "map" $connection.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside mariaDb.connection object but type is :%s" ( kindOf $connection.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictMariaDbRef */}}
    {{- $parameterCheckDictMariaDbRef := dict }}
    {{- $parameterCheckDictMariaDbRefMandatoryKeys := ( list "name" ) }}
    {{- $_ := set $parameterCheckDictMariaDbRef "fromDict" $connection }}
    {{- $_ := set $parameterCheckDictMariaDbRef "masterKey" "mariaDbRef" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "baseKey" "connection" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "mandatoryKeys" $parameterCheckDictMariaDbRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictMariaDbRef }}

    {{- /* CHECK parameterCheckDictPasswordSecretKeyRef */}}
    {{- $parameterCheckDictPasswordSecretKeyRef := dict }}
    {{- $parameterCheckDictPasswordSecretKeyRefMandatoryKeys := ( list "name" "key" ) }}
    {{- $_ := set $parameterCheckDictPasswordSecretKeyRef "fromDict" $connection }}
    {{- $_ := set $parameterCheckDictPasswordSecretKeyRef "masterKey" "passwordSecretKeyRef" }}
    {{- $_ := set $parameterCheckDictPasswordSecretKeyRef "baseKey" "connection" }}
    {{- $_ := set $parameterCheckDictPasswordSecretKeyRef "mandatoryKeys" $parameterCheckDictPasswordSecretKeyRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictPasswordSecretKeyRef }}

{{- /* TEMPLATE */}}
---
apiVersion: mariadb.mmontes.io/v1alpha1
kind: Connection
metadata:
  name: {{ $connection.name }}
  namespace: {{ $connection.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $connection.additionalLabels }}
{{ toYaml $connection.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $connection.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $connection.additionalAnnotations }}
{{ toYaml $connection.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  username: {{ $connection.username }}
  mariaDbRef:
    name: {{ $connection.mariaDbRef.name }}
    {{- $parameterMariaDbRef := dict }}
    {{- $avoidKeysMariaDbRef := ( list "name" ) }}
    {{- $_ := set $parameterMariaDbRef "fromDict" $connection.mariaDbRef }}
    {{- $_ := set $parameterMariaDbRef "avoidList" $avoidKeysMariaDbRef }}
    {{- $mariaDbRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterMariaDbRef ) }}
    {{- if $mariaDbRefAdditionnalInfos }}
{{ toYaml $mariaDbRefAdditionnalInfos | indent 4 }}
    {{- /* END IF mariaDbRefAdditionnalInfos */}}
    {{- end }}
  passwordSecretKeyRef:
    key: {{ $connection.passwordSecretKeyRef.name }}
    name: {{ $connection.passwordSecretKeyRef.name }}
    {{- $parameterPasswordSecretKeyRef := dict }}
    {{- $avoidKeysPasswordSecretKeyRef := ( list "name" "key" ) }}
    {{- $_ := set $parameterPasswordSecretKeyRef "fromDict" $connection.passwordSecretKeyRef }}
    {{- $_ := set $parameterPasswordSecretKeyRef "avoidList" $avoidKeysPasswordSecretKeyRef }}
    {{- $passwordSecretKeyRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterPasswordSecretKeyRef ) }}
    {{- if $passwordSecretKeyRefAdditionnalInfos }}
{{ toYaml $passwordSecretKeyRefAdditionnalInfos | indent 4 }}
    {{- /* END IF passwordSecretKeyRefAdditionnalInfos */}}
    {{- end }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $connection }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $connectionAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $connectionAdditionnalInfos }}
{{ toYaml $connectionAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
