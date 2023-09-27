{{- /* library template for mariaDb mariadb definition */}}
{{- /* Parametre / Values
BEGVAL

mariaDb:
  # -- Create mariaDb operator
  # @default -- see subconfig
  ## HELPER mariadb AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  operator:
    -
      # -- (string)[REQ] name
      name: mariadb-operator
      # -- (string)[REQ] namespace
      namespace: mariadb-operator

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

ENDVAL

*/}}
{{- define "sharedlibraries.mariadb_operator" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and (not $.Values.mariaDb) }}
    {{- fail "mariadb_mariadb template loaded without mariaDb object" }}
  {{- end }}

  {{- if and (not $.Values.mariaDb.operator ) }}
    {{- fail "mariadb_mariadb template loaded without mariaDb.operator object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all operator instance
  #################################
  */}}
  {{- range $operator := $.Values.mariaDb.operator }}
    {{- /* DEBUG include "sharedlibraries.dump" $operator */}}

    {{- /*
    #################################
    CHECK mandatory operator values
    #################################
    */}}

    {{- /* CHECK operator.name */}}
    {{- if not $operator.name }}
      {{- fail "No name set inside mariaDb.operator object" }}
    {{- end }}

    {{- /* CHECK operator.namespace */}}
    {{- if not $operator.namespace }}
      {{- fail "No namespace set inside mariaDb.operator object" }}
    {{- end }}

    {{- /* CHECK operator.additionalLabels */}}
    {{- if and ( $operator.additionalLabels ) ( not ( kindIs "map" $operator.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside mariaDb.operator object but type is :%s" ( kindOf $operator.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK operator.additionalAnnotations */}}
    {{- if and ( $operator.additionalAnnotations ) ( not ( kindIs "map" $operator.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside mariaDb.operator object but type is :%s" ( kindOf $operator.additionalAnnotations ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
kind: MariadbOperator
apiVersion: helm.mariadb.mmontes.io/v1alpha1
metadata:
  name: {{ $operator.name }}
  namespace: {{ $operator.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $operator.additionalLabels }}
{{ toYaml $operator.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "00" $operator.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $operator.additionalAnnotations }}
{{ toYaml $operator.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
    {{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $operator }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $operatorAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $operatorAdditionnalInfos }}
{{ toYaml $operatorAdditionnalInfos | indent 2 }}
    {{- /* END IF $operatorAdditionnalInfos  */}}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
