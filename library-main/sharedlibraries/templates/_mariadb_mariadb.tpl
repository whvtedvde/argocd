{{- /* library template for mariaDb mariadb definition */}}
{{- /*
BEGVAL
mariaDb:
  # -- Create mariaDb mariadb
  # @default -- see subconfig
  ## HELPER mariadb AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,rootPasswordSecretKeyRef,image,volumeClaimTemplate
  mariaDb:
    -
      # -- (string)[REQ] name
      name: mariadb-outils
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
      syncWave: 00

      # -- (dict)[REQ] rootPasswordSecretKeyRef
      ## HELPER rootPasswordSecretKeyRef AdditionnalInfos
      ## write as YAML (without formating or validation) everything except:
      ## name
      ## key
      rootPasswordSecretKeyRef:
        name: mariadb-outils
        key: root-password

      # -- (dict)[REQ] image
      ## HELPER image AdditionnalInfos
      ## write as YAML (without formating or validation) everything except:
      ## repository
      image:
        # -- (string)[REQ] repository
        repository : mariadb
        # -- (string)[OPT] tag
        tag: "10.11.3"
        # -- (string)[OPT] pullPolicy
        pullPolicy: IfNotPresent

      # -- (dict)[REQ] volumeClaimTemplate
      ## HELPER volumeClaimTemplate  AdditionnalInfos
      ## write as YAML (without formating or validation)
      volumeClaimTemplate:
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

      # -- (list)[OPT] volumes
      volumes:
        - name: tmp
          emptyDir: {}

      # -- (list)[OPT] volumeMounts
      volumeMounts:
        - name: tmp
          mountPath: /tmp

      # -- (list)[OPT] env
      env:
        - name: TZ
          value: SYSTEM
      # -- (list)[OPT] env
      envFrom:
        - configMapRef:
            name: mariadb

      # -- (dict)[OPT] podSecurityContext
      podSecurityContext:
        # -- (int)[OPT] runAsUser
        runAsUser: 0
      # -- (dict)[OPT] securityContext
      securityContext:
        # -- (bool)[OPT] allowPrivilegeEscalation
        allowPrivilegeEscalation: false

      # -- (DICT)[OPT] bootstrapFrom
      ## Can be backupRef or volume.persistentVolumeClaim or volume.nfs
      bootstrapFrom:
        # -- (DICT)[OPT] backupRef
        backupRef:
          name: backup-scheduled
        # -- (DICT)[OPT] bootstrapFrom
        volume:
          # -- (DICT)[OPT] persistentVolumeClaim
          persistentVolumeClaim:
            # -- (string)[OPT] claimName
            claimName: backup-scheduled
            # -- (DICT)[OPT] nfs
          nfs:
            # -- (string)[OPT] server
            server: nas.local
            # -- (string)[OPT] path
            path: /volume1/mariadb

      # -- (string)[OPT] database
      database: mariadb

      # -- (string)[OPT] username
      username: mariadb

      # -- (int)[OPT] port
      port: 3306

      # -- (dict)[OPT] passwordSecretKeyRef
      passwordSecretKeyRef:
        name: mariadb-outils
        key: user-password

      # -- (tpl/string)[OPT] myCnf
      # @notationType -- tpl
      myCnf: |
        [mysqld]
        bind-address=0.0.0.0
        default_storage_engine=InnoDB
        binlog_format=row
        innodb_autoinc_lock_mode=2
        max_allowed_packet=256M

      # -- (dict)[OPT] myCnfConfigMapKeyRef
      myCnfConfigMapKeyRef:
        name: mariadb-outils-config
        key: myCnf

      # -- (dict)[OPT] livenessProbe
      livenessProbe:
        # -- (dict)[OPT] exec
        exec:
          # -- (list)[OPT] command
          command:
            - bash
            - -c
            - mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "SELECT 1;"
        # -- (int)[OPT] initialDelaySeconds
        initialDelaySeconds: 20
        # -- (int)[OPT] periodSeconds
        periodSeconds: 10
        # -- (int)[OPT] timeoutSeconds
        timeoutSeconds: 5

      # -- (dict)[OPT] livenessProbe
      readinessProbe:
        # -- (dict)[OPT] exec
        exec:
          # -- (list)[OPT] command
          command:
            - bash
            - -c
            - mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "SELECT 1;"
        # -- (int)[OPT] initialDelaySeconds
        initialDelaySeconds: 20
        # -- (int)[OPT] periodSeconds
        periodSeconds: 10
        # -- (int)[OPT] timeoutSeconds
        timeoutSeconds: 5

        # -- (dict)[OPT] service
        service:
          # -- (string)[OPT] type
          type: LoadBalancer
          # -- (string)[OPT] annotations
          annotations:
            metallb.universe.tf/loadBalancerIPs: 172.18.0.20
ENDVAL
*/}}
{{- define "sharedlibraries.mariadb_mariadb" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and (not $.Values.mariaDb ) }}
    {{- fail "mariadb_mariadb template loaded without mariaDb object" }}
  {{- end }}

  {{- if and (not .Values.mariaDb.mariaDb ) }}
    {{- fail "mariadb_mariadb template loaded without mariaDb.mariaDb object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "rootPasswordSecretKeyRef" "image" "volumeClaimTemplate" ) }}

  {{- /*
  #################################
  LOOP all mariaDb instance
  #################################
  */}}

  {{- range $mariaDb := $.Values.mariaDb.mariaDb }}
    {{- /* DEBUG include "sharedlibraries.dump" $mariaDb */}}

    {{- /*
    #################################
    CHECK mandatory mariaDb values
    #################################
    */}}

    {{- /* CHECK mariaDb.name */}}
    {{- if not $mariaDb.name }}
      {{- fail "No name set inside mariaDb.mariadb object" }}
    {{- end }}

    {{- /* CHECK mariaDb.namespace */}}
    {{- if not $mariaDb.namespace }}
      {{- fail "No namespace set inside mariaDb.mariadb object" }}
    {{- end }}

    {{- /* CHECK mariaDb.rootPasswordSecretKeyRef */}}
    {{- if not $mariaDb.rootPasswordSecretKeyRef }}
      {{- fail "No rootPasswordSecretKeyRef set inside mariaDb.mariadb object" }}
    {{- end }}
    {{- if and ( $mariaDb.rootPasswordSecretKeyRef  ) ( not ( kindIs "map" $mariaDb.rootPasswordSecretKeyRef  ) ) }}
      {{- fail ( printf "rootPasswordSecretKeyRef is not a DICT inside mariaDb.mariadb object but type is :%s" ( kindOf $mariaDb.rootPasswordSecretKeyRef ) ) }}
    {{- end }}

    {{- /* CHECK mariaDb.volumeClaimTemplate */}}
    {{- if not $mariaDb.volumeClaimTemplate }}
      {{- fail "No image set inside mariaDb.mariadb object" }}
    {{- end }}
    {{- if and ( $mariaDb.volumeClaimTemplate  ) ( not ( kindIs "map" $mariaDb.volumeClaimTemplate  ) ) }}
      {{- fail ( printf "volumeClaimTemplate is not a DICT inside mariaDb.mariadb object but type is :%s" ( kindOf $mariaDb.volumeClaimTemplate ) ) }}
    {{- end }}

    {{- /* CHECK mariaDb.image */}}
    {{- if not $mariaDb.image }}
      {{- fail "No image set inside mariaDb.mariadb object" }}
    {{- end }}
    {{- if and ( $mariaDb.image  ) ( not ( kindIs "map" $mariaDb.image  ) ) }}
      {{- fail ( printf "image is not a DICT inside mariaDb.mariadb object but type is :%s" ( kindOf $mariaDb.image ) ) }}
    {{- end }}

    {{- /* CHECK mariaDb.additionalLabels */}}
    {{- if and ( $mariaDb.additionalLabels ) ( not ( kindIs "map" $mariaDb.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside mariaDb.mariadb object but type is :%s" ( kindOf $mariaDb.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK mariaDb.additionalAnnotations */}}
    {{- if and ( $mariaDb.additionalAnnotations ) ( not ( kindIs "map" $mariaDb.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside mariaDb.mariadb object but type is :%s" ( kindOf $mariaDb.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictRootPasswordSecretKeyRef */}}
    {{- $parameterCheckDictRootPasswordSecretKeyRef := dict }}
    {{- $parameterCheckDictRootPasswordSecretKeyRefMandatoryKeys := ( list "name" "key" ) }}
    {{- $_ := set $parameterCheckDictRootPasswordSecretKeyRef "fromDict" $mariaDb }}
    {{- $_ := set $parameterCheckDictRootPasswordSecretKeyRef "masterKey" "rootPasswordSecretKeyRef" }}
    {{- $_ := set $parameterCheckDictRootPasswordSecretKeyRef "baseKey" "mariadb" }}
    {{- $_ := set $parameterCheckDictRootPasswordSecretKeyRef "mandatoryKeys" $parameterCheckDictRootPasswordSecretKeyRefMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictRootPasswordSecretKeyRef }}

{{- /* TEMPLATE */}}
---
apiVersion: mariadb.mmontes.io/v1alpha1
kind: MariaDB
metadata:
  name: {{ $mariaDb.name }}
  namespace: {{ $mariaDb.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $mariaDb.additionalLabels }}
{{ toYaml $mariaDb.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "00" $mariaDb.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $mariaDb.additionalAnnotations }}
{{ toYaml $mariaDb.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  rootPasswordSecretKeyRef:
    name: {{ $mariaDb.rootPasswordSecretKeyRef.name }}
    key: {{ $mariaDb.rootPasswordSecretKeyRef.key }}
    {{- $parameterRootPasswordSecretKeyRef := dict }}
    {{- $avoidKeysRootPasswordSecretKeyRef := ( list "name" "key" ) }}
    {{- $_ := set $parameterRootPasswordSecretKeyRef "fromDict" $mariaDb.rootPasswordSecretKeyRef }}
    {{- $_ := set $parameterRootPasswordSecretKeyRef "avoidList" $avoidKeysRootPasswordSecretKeyRef }}
    {{- $rootPasswordSecretKeyRefAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterRootPasswordSecretKeyRef ) }}
    {{- if $rootPasswordSecretKeyRefAdditionnalInfos }}
{{ toYaml $rootPasswordSecretKeyRefAdditionnalInfos | indent 4 }}
    {{- /* END IF rootPasswordSecretKeyRefAdditionnalInfos */}}
    {{- end }}
  volumeClaimTemplate:
    {{- $parameterRootVolumeClaimTemplate := dict }}
    {{- $avoidKeysRootVolumeClaimTemplate := list }}
    {{- $_ := set $parameterRootVolumeClaimTemplate "fromDict" $mariaDb.volumeClaimTemplate }}
    {{- $_ := set $parameterRootVolumeClaimTemplate "avoidList" $avoidKeysRootVolumeClaimTemplate }}
    {{- $volumeClaimTemplateAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterRootVolumeClaimTemplate ) }}
    {{- if $volumeClaimTemplateAdditionnalInfos }}
{{ toYaml $volumeClaimTemplateAdditionnalInfos | indent 4 }}
    {{- /* END IF volumeClaimTemplateAdditionnalInfos */}}
    {{- end }}
  image:
    {{- $parameterRootImage := dict }}
    {{- $avoidKeysImage := list }}
    {{- $_ := set $parameterRootImage "fromDict" $mariaDb.image }}
    {{- $_ := set $parameterRootImage "avoidList" $avoidKeysImage }}
    {{- $imageAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterRootImage ) }}
    {{- if $imageAdditionnalInfos }}
{{ toYaml $imageAdditionnalInfos | indent 4 }}
    {{- /* END IF imageAdditionnalInfos */}}
    {{- end }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $mariaDb }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $mariaDbAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $mariaDbAdditionnalInfos }}
{{ toYaml $mariaDbAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
