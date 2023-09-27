{{/* library template for minio tenant definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################


# -- (dict) minio
# @default -- see subconfig
# DOC: [minio](https://min.io/docs/minio/kubernetes/upstream/)
minio:
  # -- Create minio tenant
  # @default -- see subconfig
  ## HELPER tenant AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,pools
  tenant:
    -
      # -- (string)[REQ] name
      name: tenant-test
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

      # -- (list)[REQ] pools
      ## HELPER pools AdditionnalInfos
      ## write as YAML (without formating or validation) everything
      pools:
        -
          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                      - key: v1.min.io/tenant
                        operator: In
                        values:
                          - outils-s3
                      - key: v1.min.io/pool
                        operator: In
                        values:
                          - pool-0
                  topologyKey: kubernetes.io/hostname
          name: pool-0
          resources:
            requests:
              cpu: '10'
              memory: 20Gi
          servers: 3
          volumeClaimTemplate:
            metadata:
              name: data
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: '1789569706'
              storageClassName: unity-prppaihypbaie01n-fc-low1
            status: {}
          volumesPerServer: 4


      # -- (bool)[OPT] requestAutoCert
      requestAutoCert: false
      # -- (dict)[OPT] exposeServices
      exposeServices:
        # -- (bool)[OPT] console
        console: true
        # -- (bool)[OPT] minio
        minio: true

      # -- (list)[OPT] users
      users:
        - name: outils-s3-user-0
      # -- (dict)[OPT] imagePullSecret
      imagePullSecret: {}
      # -- (dict)[OPT] credsSecret
      credsSecret:
        name: outils-s3-secret
      # -- (dict)[OPT] configuration
      configuration:
        name: outils-s3-env-configuration
      # -- (string)[OPT] image
      image: 'minio/minio:RELEASE.2023-02-27T18-10-45Z'
      # -- (string)[OPT] mountPath
      mountPath: /export


*/}}
{{- define "sharedlibraries.minio_tenant" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.minio  */}}
  {{- if and ( not $.Values.minio ) }}
    {{- fail "minio_tenant template loaded without minio object" }}
  {{- end }}
  {{/* CHECK $.Values.minio.tenant  */}}
  {{- if and (not $.Values.minio.tenant) }}
    {{- fail "minio_tenant template loaded without minio.tenant object" }}
  {{- end }}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "pools" ) }}
  {{- range $tenant := $.Values.minio.tenant }}
    {{/* DEBUG include "sharedlibraries.dump" $tenant */}}
    {{/*
    ######################################
    Validation Mandatory Variables tenant
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $tenant.name
    ######################################
    */}}
    {{- if not $tenant.name }}
      {{- fail "No name set inside minio.tenant object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $tenant.namespace
    ######################################
    */}}
    {{- if not $tenant.namespace }}
      {{- fail "No namespace set inside minio.tenant object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $tenant.additionalLabels
    ######################################
    */}}
    {{- if and ( $tenant.additionalLabels ) ( not (kindIs "map" $tenant.additionalLabels ) ) }}
      {{- fail (printf "additionalLabels is not a DICT inside minio.tenant object but type is :%s" ( kindOf $tenant.additionalLabels )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $tenant.additionalAnnotations
    ######################################
    */}}
    {{- if and ($tenant.additionalAnnotations) (not (kindIs "map" $tenant.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside minio.tenant object but type is :%s" ( kindOf $tenant.additionalAnnotations )) }}
    {{- end }}
    {{/*
    ######################################
    CHECK $tenant.pools
    ######################################
    */}}
    {{- if not $tenant.pools }}
      {{- fail "No pools set inside minio.tenant object" }}
    {{- end }}
    {{- if and ($tenant.pools) (not (kindIs "slice" $tenant.pools)) }}
      {{- fail (printf "pools is not a SLICE inside minio.tenant object but type is :%s" ( kindOf $tenant.pools )) }}
    {{- end }}
apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  name: {{ $tenant.name }}
  namespace: {{ $tenant.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $tenant.additionalLabels }}
{{ toYaml $tenant.additionalLabels | indent 4 }}
    {{/* END IF tenant.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $tenant.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $tenant.additionalAnnotations }}
{{ toYaml $tenant.additionalAnnotations | indent 4 }}
    {{/* END IF tenant.additionalAnnotations */}}
    {{- end }}
spec:
  pools:
    {{- $parameterTenantPools := dict }}
    {{- $avoidKeysTenantPools := list }}
    {{- $_ := set $parameterTenantPools "fromDict" $tenant }}
    {{- $_ := set $parameterTenantPools "avoidList" $avoidKeysTenantPools }}
    {{- $tenantPoolsAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterTenantPools ) }}
    {{- if $tenantPoolsAdditionnalInfos }}
{{ toYaml $tenantPoolsAdditionnalInfos | indent 4 }}
    {{/* END IF tenantPoolsAdditionnalInfos */}}
    {{- end }}
    {{- $parametertenant := dict }}
    {{- $_ := set $parametertenant "fromDict" $tenant }}
    {{- $_ := set $parametertenant "avoidList" $avoidKeys }}
    {{- $tenantAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parametertenant ) }}
    {{- if $tenantAdditionnalInfos }}
{{ toYaml $tenantAdditionnalInfos | indent 2 }}
    {{/* END IF tenantAdditionnalInfos */}}
    {{- end }}
...
  {{/* END RANGE tenant */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
