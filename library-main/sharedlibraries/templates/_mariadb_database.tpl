{{- /* library template for mariaDb database definition */}}
{{- /*
BEGVAL
mariaDb:
  # -- Create mariaDb database
  # @default -- see subconfig
  ## HELPER database AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,mariaDbRef
  database:
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
      syncWave: 01

      # -- (dict)[REQ] mariaDbRef
      ## HELPER mariaDbRef AdditionnalInfos
      ## write as YAML (without formating or validation) everything except:
      ## name
      mariaDbRef:
        name: mariadb-outils

      # -- (string)[OPT] collate
      collate: utf8_general_ci

      # -- (string)[OPT] characterSet
      characterSet: utf8
ENDVAL
*/}}
{{- define "sharedlibraries.mariadb_database" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and (not $.Values.mariaDb) }}
    {{- fail "mariadb_database template loaded without mariaDb object" }}
  {{- end }}
  {{- if and (not $.Values.mariaDb.database ) }}
    {{- fail "mariadb_database template loaded without mariaDb.database object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "mariaDbRef" ) }}

  {{- /*
  #################################
  LOOP all database instance
  #################################
  */}}

  {{- range $database := $.Values.mariaDb.database }}
    {{- /* DEBUG include "sharedlibraries.dump" $database */}}

    {{- /*
    #################################
    CHECK mandatory database values
    #################################
    */}}

    {{- /* CHECK database.name */}}
    {{- if not $database.name }}
      {{- fail "No name set inside mariaDb.database object" }}
    {{- end }}

    {{- /* CHECK database.namespace */}}
    {{- if not $database.namespace }}
      {{- fail "No namespace set inside mariaDb.database object" }}
    {{- end }}

    {{- /* CHECK database.mariaDbRef */}}
    {{- if not $database.mariaDbRef }}
      {{- fail "No ipAddressPools set inside mariaDb.database object" }}
    {{- end }}
    {{- if and ( $database.mariaDbRef  ) ( not ( kindIs "map" $database.mariaDbRef  ) ) }}
      {{- fail ( printf "mariaDbRef is not a DICT inside mariaDb.database object but type is :%s" ( kindOf $database.mariaDbRef ) ) }}
    {{- end }}

    {{- /* CHECK database.additionalLabels */}}
    {{- if and ( $database.additionalLabels ) ( not ( kindIs "map" $database.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside mariaDb.database object but type is :%s" ( kindOf $database.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK database.additionalAnnotations */}}
    {{- if and ( $database.additionalAnnotations ) ( not ( kindIs "map" $database.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside mariaDb.database object but type is :%s" ( kindOf $database.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictMariaDbRef */}}
    {{- $parameterCheckDictMariaDbRef := dict }}
    {{- $parameterCheckDictMariaDbRefMandatoryKeys := ( list "name" ) }}
    {{- $_ := set $parameterCheckDictMariaDbRef "fromDict" $database }}
    {{- $_ := set $parameterCheckDictMariaDbRef "masterKey" "mariaDbRef" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "baseKey" "database" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "mandatoryKeys" $parameterCheckDictMariaDbRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictMariaDbRef }}

{{- /* TEMPLATE */}}
---
apiVersion: mariadb.mmontes.io/v1alpha1
kind: Database
metadata:
  name: {{ $database.name }}
  namespace: {{ $database.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $database.additionalLabels }}
{{ toYaml $database.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "01" $database.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $database.additionalAnnotations }}
{{ toYaml $database.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  mariaDbRef:
    name: {{ $database.mariaDbRef.name }}
    {{- $parameterMariaDbRef := dict }}
    {{- $avoidKeysMariaDbRef := ( list "name" ) }}
    {{- $_ := set $parameterMariaDbRef "fromDict" $database.mariaDbRef }}
    {{- $_ := set $parameterMariaDbRef "avoidList" $avoidKeysMariaDbRef }}
    {{- $mariaDbRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterMariaDbRef ) }}
    {{- if $mariaDbRefAdditionnalInfos }}
{{ toYaml $mariaDbRefAdditionnalInfos | indent 4 }}
    {{- /* END IF mariaDbRefAdditionnalInfos */}}
    {{- end }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $database }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $databaseAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $databaseAdditionnalInfos }}
{{ toYaml $databaseAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
