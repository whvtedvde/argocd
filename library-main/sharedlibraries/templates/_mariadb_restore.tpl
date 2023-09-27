{{- /* library template for mariaDb restore definition */}}
{{- /*
BEGVAL

mariaDb:
  # -- Create mariaDb restore
  # @default -- see subconfig
  ## HELPER restore AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations,syncWave,mariaDbRef
  restore:
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

      # -- (dict)[REQ] volume
      ## Can be storage.persistentVolumeClaim or volume.nfs
      volume:
        # -- (dict)[REQ] persistentVolumeClaim
        ## HELPER persistentVolumeClaim  AdditionnalInfos
        ## write as YAML (without formating or validation)

      # -- (dict)[OPT] backupRef
      backupRef:
        name: backup-scheduled

      # -- (int)[OPT] backoffLimit
      backoffLimit:

      # -- (string)[OPT] fileName
      ## restore from file
      fileName:

      # -- (bool)[OPT] physical
      physical: false

      # -- (dict)[OPT] resources
      resources:

      # -- (string)[OPT] restartPolicy
      restartPolicy: RestartPolicyAlways
ENDVAL
*/}}
{{- define "sharedlibraries.mariadb_restore" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and (not $.Values.mariaDb) }}
    {{- fail "mariadb_restore template loaded without mariaDb object" }}
  {{- end }}

  {{- if and (not $.Values.mariaDb.restore ) }}
    {{- fail "mariadb_restore template loaded without mariaDb.restore object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "mariaDbRef" ) }}

  {{- /*
  #################################
  LOOP all restore instance
  #################################
  */}}

  {{- range $restore := $.Values.mariaDb.restore }}
    {{- /* DEBUG include "sharedlibraries.dump" $restore */}}

    {{- /*
    #################################
    CHECK mandatory restore values
    #################################
    */}}

    {{- /* CHECK restore.name */}}
    {{- if not $restore.name }}
      {{- fail "No name set inside mariaDb.restore object" }}
    {{- end }}

    {{- /* CHECK restore.namespace */}}
    {{- if not $restore.namespace }}
      {{- fail "No namespace set inside mariaDb.restore object" }}
    {{- end }}

    {{- /* CHECK restore.mariaDbRef */}}
    {{- if not $restore.mariaDbRef }}
      {{- fail "No mariaDbRef set inside mariaDb.restore object" }}
    {{- end }}
    {{- if and ( $restore.mariaDbRef  ) ( not ( kindIs "map" $restore.mariaDbRef  ) ) }}
      {{- fail ( printf "mariaDbRef is not a DICT inside mariaDb.restore object but type is :%s" ( kindOf $restore.mariaDbRef ) ) }}
    {{- end }}

    {{- /* CHECK restore.additionalLabels */}}
    {{- if and ( $restore.additionalLabels ) ( not ( kindIs "map" $restore.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside mariaDb.restore object but type is :%s" ( kindOf $restore.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK restore.additionalAnnotations */}}
    {{- if and ( $restore.additionalAnnotations ) ( not ( kindIs "map" $restore.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside mariaDb.restore object but type is :%s" ( kindOf $restore.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictMariaDbRef */}}
    {{- $parameterCheckDictMariaDbRef := dict }}
    {{- $parameterCheckDictMariaDbRefMandatoryKeys := ( list "name" ) }}
    {{- $_ := set $parameterCheckDictMariaDbRef "fromDict" $restore }}
    {{- $_ := set $parameterCheckDictMariaDbRef "masterKey" "mariaDbRef" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "baseKey" "restore" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "mandatoryKeys" $parameterCheckDictMariaDbRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictMariaDbRef }}

{{- /* TEMPLATE */}}
---
apiVersion: mariadb.mmontes.io/v1alpha1
kind: Restore
metadata:
  name: {{ $restore.name }}
  namespace: {{ $restore.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $restore.additionalLabels }}
{{ toYaml $restore.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "02" $restore.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $restore.additionalAnnotations }}
{{ toYaml $restore.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  mariaDbRef:
    name: {{ $restore.mariaDbRef.name }}
    {{- $parameterMariaDbRef := dict }}
    {{- $avoidKeysMariaDbRef := ( list "name" ) }}
    {{- $_ := set $parameterMariaDbRef "fromDict" $restore.mariaDbRef }}
    {{- $_ := set $parameterMariaDbRef "avoidList" $avoidKeysMariaDbRef }}
    {{- $mariaDbRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterMariaDbRef ) }}
    {{- if $mariaDbRefAdditionnalInfos }}
{{ toYaml $mariaDbRefAdditionnalInfos | indent 4 }}
    {{- /* END IF mariaDbRefAdditionnalInfos */}}
    {{- end }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $restore }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $restoreAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $restoreAdditionnalInfos }}
{{ toYaml $restoreAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
