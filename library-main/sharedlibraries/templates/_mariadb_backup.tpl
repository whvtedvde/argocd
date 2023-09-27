{{- /* library template for mariaDb backup definition */}}
{{- /*
BEGVAL
{{- /*
######################################
    Parametre / Values
######################################
mariaDb:
  # -- Create mariaDb backup
  # @default -- see subconfig
  ## HELPER backup AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations,syncWave,mariaDbRef,storage
  backup:
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

      # -- (dict)[REQ] storage
      ## Can be storage.persistentVolumeClaim or volume.nfs
      storage:
        # -- (dict)[REQ] persistentVolumeClaim
        ## HELPER persistentVolumeClaim  AdditionnalInfos
        ## write as YAML (without formating or validation)
        persistentVolumeClaim:
          # -- (dict)[REQ] resources
          resources:
            # -- (dict)[REQ] requests
            requests:
              # -- (string)[REQ] storage
              storage: 100Mi
          # -- (string)[REQ] storageClassName
          storageClassName: unity-prppaihypbaie01n-fc-low1
          # -- (list)[REQ] accessModes
          accessModes:
            - ReadWriteOnce
          # -- (dict)[REQ] volumes
          volumes:
            # -- (DICT)[OPT] nfs
            nfs:
              # -- (string)[OPT] server
              server: nas.local
              # -- (string)[OPT] path
              path: /volume1/mariadb
      # -- (dict)[OPT] schedule
      schedule:
        ### Escape end of comment to keep helm template comment
        cron: ""
        suspend: false

      # -- (int)[OPT] maxRetentionDays
      maxRetentionDays: 30

      # -- (int)[OPT] backoffLimit
      backoffLimit:

      # -- (bool)[OPT] physical
      physical: false

      # -- (dict)[OPT] resources
      resources:

      # -- (string)[OPT] restartPolicy
      restartPolicy: RestartPolicyAlways
ENDVAL
*/}}

{{- define "sharedlibraries.mariadb_backup" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and (not $.Values.mariaDb) }}
    {{- fail "mariadb_backup template loaded without mariaDb object" }}
  {{- end }}

  {{- if and (not $.Values.mariaDb.backup ) }}
    {{- fail "mariadb_backup template loaded without mariaDb.backup object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "mariaDbRef" "storage" ) }}

  {{- /*
  #################################
  LOOP all backup instance
  #################################
  */}}

  {{- range $backup := $.Values.mariaDb.backup }}
    {{- /* DEBUG include "sharedlibraries.dump" $backup */}}

    {{- /*
    #################################
    CHECK mandatory backup values
    #################################
    */}}

    {{- /* CHECK backup.name */}}
    {{- if not $backup.name }}
      {{- fail "No name set inside mariaDb.backup object" }}
    {{- end }}

    {{- /* CHECK backup.namespace */}}
    {{- if not $backup.namespace }}
      {{- fail "No namespace set inside mariaDb.backup object" }}
    {{- end }}

    {{- /* CHECK backup.mariaDbRef */}}
    {{- if not $backup.mariaDbRef }}
      {{- fail "No mariaDbRef set inside mariaDb.backup object" }}
    {{- end }}
    {{- if and ( $backup.mariaDbRef ) ( not ( kindIs "map" $backup.mariaDbRef  ) ) }}
      {{- fail ( printf "mariaDbRef is not a DICT inside mariaDb.backup object but type is :%s" ( kindOf $backup.mariaDbRef ) ) }}
    {{- end }}

    {{- /* CHECK backup.storage */}}
    {{- if not $backup.storage }}
      {{- fail "No storage set inside mariaDb.backup object" }}
    {{- end }}
    {{- if and ( $backup.storage ) ( not ( kindIs "map" $backup.storage  ) ) }}
      {{- fail ( printf "storage is not a DICT inside mariaDb.backup object but type is :%s" ( kindOf $backup.storage ) ) }}
    {{- end }}

    {{- /* CHECK backup.storage.persistentVolumeClaim  backup.storage.volume  */}}
    {{- if and ( not $backup.storage.persistentVolumeClaim ) ( not $backup.storage.volume ) }}
      {{- fail "No persistentVolumeClaim or volume set inside mariaDb.mariadb.storage object" }}
    {{- end }}
    {{- if and ( $backup.storage.persistentVolumeClaim  ) ( not ( kindIs "map" $backup.storage.persistentVolumeClaim ) ) }}
      {{- fail ( printf "persistentVolumeClaim is not a DICT inside mariaDb.backup.storage object but type is :%s" ( kindOf $backup.storage.persistentVolumeClaim ) ) }}
    {{- end }}
    {{- if and ( $backup.storage.volume  ) ( not ( kindIs "map" $backup.storage.volume ) ) }}
      {{- fail ( printf "volume is not a DICT inside backup.backup.storage object but type is :%s" ( kindOf $backup.storage.volume ) ) }}
    {{- end }}

    {{- /* CHECK backup.additionalLabels */}}
    {{- if and ( $backup.additionalLabels ) ( not ( kindIs "map" $backup.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside mariaDb.backup object but type is :%s" ( kindOf $backup.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK backup.additionalAnnotations */}}
    {{- if and ( $backup.additionalAnnotations ) ( not ( kindIs "map" $backup.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside mariaDb.backup object but type is :%s" ( kindOf $backup.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictMariaDbRef */}}
    {{- $parameterCheckDictMariaDbRef := dict }}
    {{- $parameterCheckDictMariaDbRefMandatoryKeys := ( list "name" ) }}
    {{- $_ := set $parameterCheckDictMariaDbRef "fromDict" $backup }}
    {{- $_ := set $parameterCheckDictMariaDbRef "masterKey" "mariaDbRef" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "baseKey" "backup" }}
    {{- $_ := set $parameterCheckDictMariaDbRef "mandatoryKeys" $parameterCheckDictMariaDbRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictMariaDbRef }}

{{- /* TEMPLATE */}}
---
apiVersion: mariadb.mmontes.io/v1alpha1
kind: Backup
metadata:
  name: {{ $backup.name }}
  namespace: {{ $backup.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $backup.additionalLabels }}
{{ toYaml $backup.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "02" $backup.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $backup.additionalAnnotations }}
{{ toYaml $backup.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  mariaDbRef:
    name: {{ $backup.mariaDbRef.name }}
    {{- $parameterMariaDbRef := dict }}
    {{- $avoidKeysMariaDbRef := ( list "name" ) }}
    {{- $_ := set $parameterMariaDbRef "fromDict" $backup.mariaDbRef }}
    {{- $_ := set $parameterMariaDbRef "avoidList" $avoidKeysMariaDbRef }}
    {{- $mariaDbRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterMariaDbRef ) }}
    {{- if $mariaDbRefAdditionnalInfos }}
{{ toYaml $mariaDbRefAdditionnalInfos | indent 4 }}
    {{- /* END IF mariaDbRefAdditionnalInfos */}}
    {{- end }}
  storage:
    {{- if $backup.storage.persistentVolumeClaim }}
    persistentVolumeClaim:
      {{- $parameterPersistentVolumeClaim := dict }}
      {{- $avoidKeysPersistentVolumeClaim := list }}
      {{- $_ := set $parameterPersistentVolumeClaim "fromDict" $backup.storage.persistentVolumeClaim }}
      {{- $_ := set $parameterPersistentVolumeClaim "avoidList" $avoidKeysPersistentVolumeClaim }}
      {{- $persistentVolumeClaimAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterPersistentVolumeClaim ) }}
      {{- if $persistentVolumeClaimAdditionnalInfos }}
{{ toYaml $persistentVolumeClaimAdditionnalInfos | indent 6 }}
      {{- /* END IF persistentVolumeClaimAdditionnalInfos */}}
      {{- end }}
    {{- /* END IF $backup.storage.persistentVolumeClaim */}}
    {{- end }}
    {{- if $backup.storage.volume }}
    volume:
      {{- $parameterVolume := dict }}
      {{- $avoidKeysVolume := list }}
      {{- $_ := set $parameterVolume "fromDict" $backup.storage.volume }}
      {{- $_ := set $parameterVolume "avoidList" $avoidKeysVolume }}
      {{- $volumeAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterVolume ) }}
      {{- if $volumeAdditionnalInfos }}
{{ toYaml $volumeAdditionnalInfos | indent 6 }}
      {{- /* END IF volumeAdditionnalInfos */}}
      {{- end }}
    {{- /* END IF $backup.storage.volume */}}
    {{- end }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $backup }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $backupAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $backupAdditionnalInfos }}
{{ toYaml $backupAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
