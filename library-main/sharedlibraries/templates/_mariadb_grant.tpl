{{- /* library template for mariaDb grant definition */}}
{{- /*
BEGVAL
mariaDb:
  # -- Create mariaDb grant
  # @default -- see subconfig
  ## HELPER grant AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,mariaDbRef,username,privileges
  grant:
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
      syncWave: 03

      # -- (dict)[REQ] mariaDbRef
      ## HELPER mariaDbRef AdditionnalInfos
      ## write as YAML (without formating or validation) everything except:
      ## name
      mariaDbRef:
        name: mariadb-outils

      # -- (string)[REQ] username
      username: testdb

      # -- (list)[REQ] privileges
      privileges:
        - SELECT
        - INSERT
        - UPDATE
        - CREATE
        - DELETE
        - ALTER

      # -- (string)[OPT] table
      # @default --  '*'
      table: '*'

      # -- (bool)[OPT] grantOption
      ## Allow user to add grant privileges
      grantOption: false

      # -- (string)[OPT] database
      # @default --  '*'
      database: '*'
ENDVAL
*/}}
{{- define "sharedlibraries.mariadb_grant" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and (not $.Values.mariaDb) }}
    {{- fail "mariadb_grant template loaded without mariaDb object" }}
  {{- end }}

  {{- if and (not $.Values.mariaDb.grant ) }}
    {{- fail "mariadb_grant template loaded without mariaDb.grant object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "mariaDbRef" "username" "privileges" ) }}

  {{- /*
  #################################
  LOOP all grant instance
  #################################
  */}}

  {{- range $grant := $.Values.mariaDb.grant }}
    {{- /* DEBUG include "sharedlibraries.dump" $grant */}}

    {{- /*
    #################################
    CHECK mandatory grant values
    #################################
    */}}

    {{- /* CHECK grant.name */}}
    {{- if not $grant.name }}
      {{- fail "No name set inside mariaDb.grant object" }}
    {{- end }}

    {{- /* CHECK grant.namespace */}}
    {{- if not $grant.namespace }}
      {{- fail "No namespace set inside mariaDb.grant object" }}
    {{- end }}

    {{- /* CHECK grant.mariaDbRef */}}
    {{- if not $grant.mariaDbRef }}
      {{- fail "No ipAddressPools set inside mariaDb.grant object" }}
    {{- end }}
    {{- if and ( $grant.mariaDbRef ) ( not ( kindIs "map" $grant.mariaDbRef  ) ) }}
      {{- fail ( printf "mariaDbRef is not a DICT inside mariaDb.grant object but type is :%s" ( kindOf $grant.mariaDbRef ) ) }}
    {{- end }}

    {{- /* CHECK grant.username */}}
    {{- if not $grant.username  }}
      {{- fail "No username  set inside mariaDb.grant object" }}
    {{- end }}

    {{- /* CHECK grant.privileges */}}
    {{- if not $grant.privileges  }}
      {{- fail "No privileges  set inside mariaDb.grant object" }}
    {{- end }}
    {{- if and ( $grant.privileges ) ( not ( kindIs "slice" $grant.privileges   ) ) }}
      {{- fail ( printf "privileges  is not a LIST inside mariaDb.grant object but type is :%s" ( kindOf $grant.privileges  ) ) }}
    {{- end }}

    {{- /* CHECK grant.additionalLabels */}}
    {{- if and ( $grant.additionalLabels ) ( not ( kindIs "map" $grant.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside mariaDb.grant object but type is :%s" ( kindOf $grant.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK grant.additionalAnnotations */}}
    {{- if and ( $grant.additionalAnnotations ) ( not ( kindIs "map" $grant.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside mariaDb.grant object but type is :%s" ( kindOf $grant.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictMariaDbRef */}}
    {{- $parameterCheckDictMariaDbRef := dict }}
    {{- $parameterCheckDictMariaDbRefMandatoryKeys := ( list "name" ) }}
    {{- $_ := set $parameterCheckDictMariaDbRef "fromDict" $grant }}
    {{- $_ := set $parameterCheckDictMariaDbRef "masterKey" "mariaDbRef" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "baseKey" "grant" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "mandatoryKeys" $parameterCheckDictMariaDbRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictMariaDbRef }}

{{- /* TEMPLATE */}}
---
apiVersion: mariadb.mmontes.io/v1alpha1
kind: Grant
metadata:
  name: {{ $grant.name }}
  namespace: {{ $grant.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $grant.additionalLabels }}
{{ toYaml $grant.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "03" $grant.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $grant.additionalAnnotations }}
{{ toYaml $grant.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  mariaDbRef:
    name: {{ $grant.mariaDbRef.name }}
    {{- $parameterMariaDbRef := dict }}
    {{- $avoidKeysMariaDbRef := ( list "name" ) }}
    {{- $_ := set $parameterMariaDbRef "fromDict" $grant.mariaDbRef }}
    {{- $_ := set $parameterMariaDbRef "avoidList" $avoidKeysMariaDbRef }}
    {{- $mariaDbRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterMariaDbRef ) }}
    {{- if $mariaDbRefAdditionnalInfos }}
{{ toYaml $mariaDbRefAdditionnalInfos | indent 4 }}
    {{- /* END IF mariaDbRefAdditionnalInfos */}}
    {{- end }}
  username: {{ $grant.username }}
  privileges:
{{ toYaml $grant.privileges | indent 4 }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $grant }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $grantAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $grantAdditionnalInfos }}
{{ toYaml $grantAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
