{{/* library template for  RBAC roleBinding and/or clusterRoleBinding definition*/}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################

# -- (dict) RBAC definition
# @default -- see subconfig
# DOC: [RBAC](https://docs.openshift.com/container-platform/4.12/authentication/using-rbac.html)
rbac:
  # -- (dict) cluster role binding
  crb:
    -
      # -- (string)[REQ] name
      name: "crb-test"

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

      # -- (list)[REQ] subjects
      ## HELPER rules AdditionnalInfos
      ## write as yaml with validation
      subjects:
          # -- (list)[REQ] kind
        - kind: Group
          # name
          # [REQ]
          name: 'system:serviceaccounts:sa-test'
          # apiGroup
          # [REQ]
          apiGroup: rbac.authorization.k8s.io

      # -- (list)[REQ] roleRef
      ## HELPER rules AdditionnalInfos
      ## write as yaml with validation
      roleRef:
        # kind
        # [REQ]
        kind: Role
        # name
        # [REQ]
        name: cr-test
        # apiGroup
        # [REQ]
        apiGroup: rbac.authorization.k8s.io

  # -- (dict) role binding
  rb:
    -
      # -- (string)[REQ] name
      name: "rb-test"
      # RoleBinding namespace
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
      syncWave: 00

      # -- (list)[REQ] subjects
      ## HELPER rules AdditionnalInfos
      ## write as yaml with validation
      subjects:
          # kind
          # [REQ]
        - kind: Group
          # name
          # [REQ]
          name: 'system:serviceaccounts:sa-test'
          # apiGroup
          # [REQ]
          apiGroup: rbac.authorization.k8s.io

      # -- (list)[REQ] roleRef
      ## HELPER rules AdditionnalInfos
      ## write as yaml with validation
      roleRef:
        # kind
        # [REQ]
        kind: Role
        # name
        # [REQ]
        name: r-test
        # apiGroup
        # [REQ]
        apiGroup: rbac.authorization.k8s.io
*/}}
{{- define "sharedlibraries.rbac_binding" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.rbac.crb and/or $.Values.rbac.rb  */}}
  {{- if and (not $.Values.rbac.crb) (not $.Values.rbac.rb) }}
    {{- fail "rbac_binding template loaded without rbac.rb or/and rbac.crb object" }}
  {{- end }}
  {{/*
  ######################################
  Handle ClusterRoleBinding
  ######################################
  */}}
  {{- if $.Values.rbac.crb }}
    {{- range $clusterRoleBinding := $.Values.rbac.crb }}
      {{/* DEBUG include "sharedlibraries.dump" $clusterRoleBinding */}}
      {{/*
      ######################################
      Validation Mandatory Variables clusterRoleBinding
      ######################################
      */}}
      {{/*
      ######################################
      CHECK $clusterRoleBinding.name
      ######################################
      */}}
      {{- if not $clusterRoleBinding.name }}
      {{- fail "No name set inside rbac.crb object" }}
      {{- end }}
      {{/*
      ######################################
      CHECK $clusterRoleBinding.subjects
      ######################################
      */}}
      {{- $parameterCheckDictClusterSubjects := dict }}
      {{- $parameterCheckDictClusterSubjectsMandatoryKeys := ( list "namespace" "kind" "name" ) }}
      {{- $_ := set $parameterCheckDictClusterSubjects "fromDict" $clusterRoleBinding }}
      {{- $_ := set $parameterCheckDictClusterSubjects "masterKey" "subjects" }}
      {{- $_ := set $parameterCheckDictClusterSubjects "baseKey" "rbac.crb" }}
      {{- $_ := set $parameterCheckDictClusterSubjects "mandatoryKeys" $parameterCheckDictClusterSubjectsMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableList" $parameterCheckDictClusterSubjects }}
      {{/*
      ######################################
      CHECK $clusterRoleBinding.roleRef
      ######################################
      */}}
      {{- $parameterCheckDictClusterRoleRef := dict }}
      {{- $parameterCheckDictClusterRoleRefMandatoryKeys := ( list "apiGroup" "kind" "name" ) }}
      {{- $_ := set $parameterCheckDictClusterRoleRef "fromDict" $clusterRoleBinding }}
      {{- $_ := set $parameterCheckDictClusterRoleRef "masterKey" "roleRef" }}
      {{- $_ := set $parameterCheckDictClusterRoleRef "baseKey" "rbac.crb" }}
      {{- $_ := set $parameterCheckDictClusterRoleRef "mandatoryKeys" $parameterCheckDictClusterRoleRefMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictClusterRoleRef }}
      {{/*
      ######################################
      CHECK KIND $clusterRoleBinding.additionalLabels
      ######################################
      */}}
      {{- if and ($clusterRoleBinding.additionalLabels) (not (kindIs "map" $clusterRoleBinding.additionalLabels)) }}
        {{- fail (printf "additionalLabels is not a DICT inside rbac.crb object but type is :%s" (kindOf $clusterRoleBinding.additionalLabels)) }}
      {{- end }}
      {{/*
      ######################################
      CHECK KIND $clusterRoleBinding.additionalAnnotations
      ######################################
      */}}
      {{- if and ($clusterRoleBinding.additionalAnnotations) (not (kindIs "map" $clusterRoleBinding.additionalAnnotations)) }}
        {{- fail (printf "additionalAnnotations is not a DICT inside rbac.crb object but type is :%s" (kindOf $clusterRoleBinding.additionalAnnotations)) }}
      {{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $clusterRoleBinding.name }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
      {{- if $clusterRoleBinding.additionalLabels }}
{{ toYaml $clusterRoleBinding.additionalLabels | indent 4 }}
      {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "00" $clusterRoleBinding.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
      {{- if $clusterRoleBinding.additionalAnnotations }}
{{ toYaml $clusterRoleBinding.additionalAnnotations | indent 4 }}
      {{- end }}
subjects:
      {{- if $clusterRoleBinding.subjects }}
{{ toYaml $clusterRoleBinding.subjects | indent 2 }}
      {{- end }}
roleRef:
      {{- if $clusterRoleBinding.roleRef }}
{{ toYaml $clusterRoleBinding.roleRef | indent 2 }}
      {{- end }}
...
    {{/* END RANGE */}}
    {{- end }}
  {{/* END IF Handle ClusterRoleBinding */}}
  {{- end }}
  {{/*
  ######################################
  Handle RoleBinding
  ######################################
  */}}
  {{- if $.Values.rbac.rb }}
    {{- range $roleBinding := $.Values.rbac.rb }}
      {{/* DEBUG include "sharedlibraries.dump" $roleBinding */}}
      {{/*
      ######################################
      Validation Mandatory Variables roleBinding
      ######################################
      */}}
      {{/*
      ######################################
      CHECK $roleBinding.name
      ######################################
      */}}
      {{- if not $roleBinding.name }}
        {{- fail "No name set inside rbac.rb object" }}
      {{- end }}
      {{/*
      ######################################
      CHECK $roleBinding.namespace
      ######################################
      */}}
      {{- if not $roleBinding.namespace }}
        {{- fail "No namespace set inside rbac.rb object" }}
      {{- end }}
      {{/*
      ######################################
      CHECK $roleBinding.subjects
      ######################################
      */}}
      {{- $parameterCheckDictSubjects := dict }}
      {{- $parameterCheckDictSubjectsMandatoryKeys := ( list "namespace" "kind" "name" ) }}
      {{- $_ := set $parameterCheckDictSubjects "fromDict" $roleBinding }}
      {{- $_ := set $parameterCheckDictSubjects "masterKey" "subjects" }}
      {{- $_ := set $parameterCheckDictSubjects "baseKey" "rbac.rb" }}
      {{- $_ := set $parameterCheckDictSubjects "mandatoryKeys" $parameterCheckDictSubjectsMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableList" $parameterCheckDictSubjects }}
      {{/*
      ######################################
      CHECK $roleBinding.roleRef
      ######################################
      */}}
      {{- $parameterCheckDictRoleRef := dict }}
      {{- $parameterCheckDictRoleRefMandatoryKeys := ( list "apiGroup" "kind" "name" ) }}
      {{- $_ := set $parameterCheckDictRoleRef "fromDict" $roleBinding }}
      {{- $_ := set $parameterCheckDictRoleRef "masterKey" "roleRef" }}
      {{- $_ := set $parameterCheckDictRoleRef "baseKey" "rbac.rb" }}
      {{- $_ := set $parameterCheckDictRoleRef "mandatoryKeys" $parameterCheckDictRoleRefMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableDict" $parameterCheckDictRoleRef }}
      {{/*
      ######################################
      CHECK KIND $roleBinding.additionalLabels
      ######################################
      */}}
      {{- if and ($roleBinding.additionalLabels) (not (kindIs "map" $roleBinding.additionalLabels)) }}
        {{- fail (printf "additionalLabels is not a DICT inside rbac.rb object but type is :%s" (kindOf $roleBinding.additionalLabels)) }}
      {{- end }}
      {{/*
      ######################################
      CHECK KIND $roleBinding.additionalAnnotations
      ######################################
      */}}
      {{- if and ($roleBinding.additionalAnnotations) (not (kindIs "map" $roleBinding.additionalAnnotations)) }}
        {{- fail (printf "additionalAnnotations is not a DICT inside rbac.rb object but type is :%s" (kindOf $roleBinding.additionalAnnotations)) }}
      {{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $roleBinding.name }}
  namespace: {{ $roleBinding.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
      {{- if $roleBinding.additionalLabels }} {{/* # ADD additionalLabels   */}}
{{ toYaml $roleBinding.additionalLabels | indent 4 }}
      {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "00" $roleBinding.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
      {{- if $roleBinding.additionalAnnotations }} {{/* # ADD additionalAnnotations   */}}
{{ toYaml $roleBinding.additionalAnnotations | indent 4 }}
      {{- end }}
subjects:
{{ toYaml $roleBinding.subjects | indent 2 }}
roleRef:
{{ toYaml $roleBinding.roleRef | indent 2 }}
...
    {{/* END RANGE */}}
    {{- end }}
  {{/* END IF Handle RoleBinding */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
