{{- /* library template for  RBAC serviceAccount definition*/}}
{{- /*
BEGVAL
# -- (dict) RBAC definition
# @default -- see subconfig
# DOC: [RBAC](https://docs.openshift.com/container-platform/4.12/authentication/using-rbac.html)
rbac:

  # -- (dict) ServiceAccount (sa)
  ## HELPER serviceaccount(sa) AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  sa:
    -
      # -- (string)[REQ] name
      name: sa-test

      # ServiceAccount namespace
      # [REQ]
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
      syncWave: -1

ENDVAL
*/}}

{{- define "sharedlibraries.rbac_serviceaccount" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if not $.Values.rbac.sa }}
    {{- fail "rbac_serviceaccount template loaded without rbac.sa object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all serviceAccount instance
  #################################
  */}}
  {{- range $serviceAccount := $.Values.rbac.sa }}
    {{- /* DEBUG include "sharedlibraries.dump" $serviceAccount */}}

    {{- /*
    #################################
    CHECK mandatory serviceAccount values
    #################################
    */}}

    {{- /* CHECK serviceAccount.name */}}
    {{- if not $serviceAccount.name }}
      {{- fail "No name set inside rbac.sa object" }}
    {{- end }}

    {{- /* CHECK serviceAccount.namespace */}}
    {{- if not $serviceAccount.namespace }}
      {{- fail "No namespace set inside rbac.sa object" }}
    {{- end }}

    {{- /* CHECK serviceAccount.additionalLabels */}}
    {{- if and ( $serviceAccount.additionalLabels ) ( not ( kindIs "map" $serviceAccount.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside rbac.sa object but type is :%s" ( kindOf $serviceAccount.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK serviceAccount.additionalAnnotations */}}
    {{- if and ( $serviceAccount.additionalAnnotations ) ( not ( kindIs "map" $serviceAccount.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside rbac.sa object but type is :%s" ( kindOf $serviceAccount.additionalAnnotations ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $serviceAccount.name }}
  namespace: {{ $serviceAccount.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $serviceAccount.additionalLabels }}
{{ toYaml $serviceAccount.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "-1" $serviceAccount.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $serviceAccount.additionalAnnotations }}
{{ toYaml $serviceAccount.additionalAnnotations | indent 4 }}
    {{- end }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $serviceAccount }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $serviceAccountAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $serviceAccountAdditionnalInfos }}
{{ toYaml $serviceAccountAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
