{{- /* library template for storage persistentvolumeclaims definition */}}
{{- /* Parametre / Values
BEGVAL

# -- (dict) storage definition
# @default -- see subconfig
# DOC: [storage](https://kubernetes.io/docs/concepts/storage)
storage:
  # -- (dict) storage persistentvolumeclaims
  # @default -- see subconfig
  # DOC : [storage](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)
  ## HELPER storage persistentvolumeclaims AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, accessModes, storageClassName, volumeMode
  persistentvolumeclaims:
    -
      # -- (string)[REQ] name
      name: storage-persistentvolumeclaims-test
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
        # -- (string)[OPT] Disable delete storage from argocd
        argocd.argoproj.io/sync-options: Delete=false
        # -- (string)[OPT] additionnal annotations exemple
        # @ignored
        additionalAnnotationsTest: test
      # -- (int)[OPT] ArgoCD syncwave annotation
      # @ignored
      syncWave: 04

      # -- (list)[REQ] accessModes
      ## can be ReadWriteOnce / ReadOnlyMany / ReadWriteMany / ReadWriteOncePod
      accessModes:
        - ReadWriteOnce

      # -- (string)[REQ] storageClassName
      storageClassName: unity-prppaihypbaie01n-fc-low1-immediate
      # -- (string)[REQ] volumeMode
      ## can be Block / Filesystem
      volumeMode: Block

      # -- (string)[OPT] PV Name
      volumeName: csiunity-4db29b90b1

      # -- (dict)[OPT] resources
      ## Ressources definition
      resources:
        # -- (dict)[OPT] limits
        limits:
          # -- (int)[OPT] limits storage
          ## Set as interger or with units
          ## like "2Gi"
          storage: '42949672960'
        # -- (dict)[OPT] requests
        requests:
          # -- (int)[OPT] requests storage
          ## Set as interger or with units
          ## like "2Gi"
          storage: '42949672960'

      # selector:
      # dataSource:
        # kind: PersistentVolumeClaim
        # name: pvc-1

ENDVAL

*/}}
{{- define "sharedlibraries.storage_persistentvolumeclaims" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.storage ) }}
    {{- fail "storage_persistentvolumeclaims template loaded without storage object" }}
  {{- end }}

  {{- if and ( not $.Values.storage.persistentVolumeClaims ) }}
    {{- fail "storage_persistentvolumeclaims template loaded without storage.persistentVolumeClaims object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "accessModes" "storageClassName" "volumeMode" ) }}

  {{- /*
  #################################
  LOOP all persistentvolumeclaims instance
  #################################
  */}}
  {{- range $persistentVolumeClaims := $.Values.storage.persistentVolumeClaims }}
    {{- /* DEBUG include "sharedlibraries.dump" $persistentVolumeClaims */}}


    {{- /* CHECK persistentvolumeclaims.name */}}
    {{- if not $persistentVolumeClaims.name }}
      {{- fail "No name set inside storage.persistentVolumeClaims object" }}
    {{- end }}

    {{- /* CHECK persistentvolumeclaims.namespace */}}
    {{- if not $persistentVolumeClaims.namespace }}
      {{- fail "No namespace set inside storage.persistentVolumeClaims object" }}
    {{- end }}

    {{- /* CHECK persistentvolumeclaims.additionalLabels */}}
    {{- if and ( $persistentVolumeClaims.additionalLabels ) ( not ( kindIs "map" $persistentVolumeClaims.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside storage.persistentVolumeClaims object but type is :%s" ( kindOf $persistentVolumeClaims.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK persistentvolumeclaims.additionalAnnotations */}}
    {{- if and ( $persistentVolumeClaims.additionalAnnotations ) ( not ( kindIs "map" $persistentVolumeClaims.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside storage.persistentVolumeClaims object but type is :%s" ( kindOf $persistentVolumeClaims.additionalAnnotations  ) ) }}
    {{- end }}

    {{- /* CHECK persistentvolumeclaims.accessModes */}}
    {{- if not $persistentVolumeClaims.accessModes }}
      {{- fail "No accessModes set inside storage.persistentVolumeClaims object" }}
    {{- end }}
    {{- if not ( kindIs "slice" $persistentVolumeClaims.accessModes ) }}
      {{- fail ( printf "accessModes is not a LIST inside storage.persistentVolumeClaims object but type is :%s" ( kindOf $persistentVolumeClaims.accessModes  ) ) }}
    {{- end }}

    {{- /* CHECK persistentvolumeclaims.storageClassName */}}
    {{- if not $persistentVolumeClaims.storageClassName }}
      {{- fail "No storageClassName set inside storage.persistentVolumeClaims object" }}
    {{- end }}

    {{- /* CHECK persistentvolumeclaims.volumeMode */}}
    {{- if not $persistentVolumeClaims.volumeMode }}
      {{- fail "No volumeMode set inside storage.persistentVolumeClaims object" }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $persistentVolumeClaims.name }}
  namespace: {{ $persistentVolumeClaims.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $persistentVolumeClaims.additionalLabels }}
{{ toYaml $persistentVolumeClaims.additionalLabels | indent 4 }}
    {{- /* END IF persistentvolumeclaims.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $persistentVolumeClaims.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $persistentVolumeClaims.additionalAnnotations }}
{{ toYaml $persistentVolumeClaims.additionalAnnotations | indent 4 }}
    {{- /* END IF persistentvolumeclaims.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameterpersistentvolumeclaimss := dict }}
    {{- $_ := set $parameterpersistentvolumeclaimss "fromDict" $persistentVolumeClaims }}
    {{- $_ := set $parameterpersistentvolumeclaimss "avoidList" $avoidKeys }}
    {{- $persistentVolumeClaimsAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterpersistentvolumeclaimss ) }}
    {{- if $persistentVolumeClaimsAdditionnalInfos }}
{{ toYaml $persistentVolumeClaimsAdditionnalInfos | indent 2 }}
    {{- /* END IF persistentvolumeclaimsAdditionnalInfos */}}
    {{- end }}
  accessModes:
{{ toYaml $persistentVolumeClaims.accessModes | indent 4 }}
  storageClassName: {{ $persistentVolumeClaims.storageClassName }}
  volumeMode: {{ $persistentVolumeClaims.volumeMode }}
...
  {{- /* END RANGE persistentvolumeclaims */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
