{{- /* library template for  RBAC role and/or clusterRole definition*/}}
{{- /* Parametre / Values
BEGVAL
# -- (dict) RBAC definition
# @default -- see subconfig
# DOC: [RBAC](https://docs.openshift.com/container-platform/4.12/authentication/using-rbac.html)
rbac:
  # -- (dict) cluster role
  cr:
    -
      # -- (string)[REQ] name
      name: "cr-test"

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

      # -- (list)[REQ] rules
      ## HELPER rules AdditionnalInfos
      ## write as yaml with validation
      rules:
           # -- (list)[REQ] apiGroups
        - apiGroups:
            - k8s.ovn.org
           # -- (list)[REQ] resources
          resources:
            - egressips
           # -- (list)[REQ] verbs
          verbs:
            - "*"
        - verbs:
            - '*'
          nonResourceURLs:
            - '*'

  # -- (dict) role
  r:
    -
      # -- (string)[REQ] name
      name: "r-test"
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
      syncWave: -1

      # -- (list)[REQ] rules
      ## HELPER rules AdditionnalInfos
      ## write as yaml with validation
      rules:
           # -- (list)[REQ] apiGroups
        - apiGroups:
            - k8s.ovn.org
           # -- (list)[REQ] resources
          resources:
            - egressips
           # -- (list)[REQ] verbs
          verbs:
            - "*"
ENDVAL

*/}}
{{- define "sharedlibraries.rbac_role" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- /* CHECK $.Values.rbac.cr and/or $.Values.rbac.r  */}}
  {{- if and (not $.Values.rbac.cr) (not $.Values.rbac.r) }}
    {{- fail "rbac_role template loaded without rbac.r or/and rbac.cr object" }}
  {{- end }}

  {{- /*
  #################################
  HANDLE rbac.cr instance
  #################################
  */}}
  {{- if $.Values.rbac.cr }}

    {{- /*
    #################################
    LOOP all rbac.cr instance
    #################################
    */}}
    {{- range $clusterRole := $.Values.rbac.cr }}
      {{- /* DEBUG include "sharedlibraries.dump" $clusterRole */}}
      {{- /*
      #################################
      CHECK mandatory clusterRole values
      #################################
      */}}
      {{- /* CHECK clusterRole.name */}}
      {{- if not $clusterRole.name }}
        {{- fail "No name set inside rbac.cr object" }}
      {{- end }}

      {{- /* CHECK KIND and MANDATORY clusterRole.rules */}}
      {{- $parameterCheckDictClusterRoleRules := dict }}
      {{- $parameterCheckDictClusterRoleRulesMandatoryKeys := ( list "apiGroups" "verbs" ) }}
      {{- $_ := set $parameterCheckDictClusterRoleRules "fromDict" $clusterRole }}
      {{- $_ := set $parameterCheckDictClusterRoleRules "masterKey" "rules" }}
      {{- $_ := set $parameterCheckDictClusterRoleRules "baseKey" "rbac.cr" }}
      {{- $_ := set $parameterCheckDictClusterRoleRules "mandatoryKeys" $parameterCheckDictClusterRoleRulesMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableList" $parameterCheckDictClusterRoleRules }}

      {{- /* CHECK clusterRole.additionalLabels */}}
      {{- if and ( $clusterRole.additionalLabels ) ( not ( kindIs "map" $clusterRole.additionalLabels ) ) }}
        {{- fail ( printf "additionalLabels is not a DICT inside rbac.cr object but type is :%s" ( kindOf $clusterRole.additionalLabels ) ) }}
      {{- end }}

      {{- /* CHECK clusterRole.additionalAnnotations */}}
      {{- if and ( $clusterRole.additionalAnnotations) ( not ( kindIs "map" $clusterRole.additionalAnnotations ) ) }}
        {{- fail ( printf "additionalAnnotations is not a DICT inside rbac.cr object but type is :%s" ( kindOf $clusterRole.additionalAnnotations ) ) }}
      {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $clusterRole.name }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
      {{- if $clusterRole.additionalLabels }}
{{ toYaml $clusterRole.additionalLabels | indent 4 }}
      {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "-1" $clusterRole.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
      {{- if $clusterRole.additionalAnnotations }}
{{ toYaml $clusterRole.additionalAnnotations | indent 4 }}
      {{- end }}
rules:
      {{- if $clusterRole.rules }}
{{ toYaml $clusterRole.rules | indent 2 }}
      {{- end }}
...
    {{- /* END RANGE */}}
    {{- end }}
  {{- /* END IF Handle ClusterRole */}}
  {{- end }}

  {{- /*
  #################################
  HANDLE rbac.r instance
  #################################
  */}}
  {{- if $.Values.rbac.r }}

    {{- /*
    #################################
    LOOP all rbac.cr instance
    #################################
    */}}
    {{- range $role := $.Values.rbac.r }}
      {{- /* DEBUG include "sharedlibraries.dump" $role */}}
      {{- /*
      #################################
      CHECK mandatory role values
      #################################
      */}}
      {{- /* CHECK role.name */}}
      {{- if not $role.name }}
        {{- fail "No name set inside rbac.r object" }}
      {{- end }}

      {{- /* CHECK role.namespace */}}
      {{- if not $role.namespace }}
        {{- fail "No namespace set inside rbac.r object" }}
      {{- end }}

      {{- /* CHECK KIND and MANDATORY role.rules */}}
      {{- $parameterCheckDictRoleRules := dict }}
      {{- $parameterCheckDictRoleRulesMandatoryKeys := ( list "apiGroups" "verbs" ) }}
      {{- $_ := set $parameterCheckDictRoleRules "fromDict" $role }}
      {{- $_ := set $parameterCheckDictRoleRules "masterKey" "rules" }}
      {{- $_ := set $parameterCheckDictRoleRules "baseKey" "rbac.r" }}
      {{- $_ := set $parameterCheckDictRoleRules "mandatoryKeys" $parameterCheckDictRoleRulesMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRoleRules }}

      {{- /* CHECK role.additionalLabels */}}
      {{- if and ( $role.additionalLabels ) ( not ( kindIs "map" $role.additionalLabels ) ) }}
        {{- fail ( printf "additionalLabels is not a DICT inside rbac.r object but type is :%s" ( kindOf $role.additionalLabels ) ) }}
      {{- end }}

      {{- /* CHECK role.additionalAnnotations */}}
      {{- if and ( $role.additionalAnnotations ) ( not ( kindIs "map" $role.additionalAnnotations ) ) }}
        {{- fail ( printf "additionalAnnotations is not a DICT inside rbac.r object but type is :%s" ( kindOf $role.additionalAnnotations ) ) }}
      {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ $role.name }}
  namespace: {{ $role.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
      {{- if $role.additionalLabels }}
{{ toYaml $role.additionalLabels | indent 4 }}
      {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "-1" $role.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
      {{- if $role.additionalAnnotations }}
{{ toYaml $role.additionalAnnotations | indent 4 }}
      {{- end }}
rules: {{ toYaml $role.rules  | nindent 2 }}
...
    {{- /* END RANGE */}}
    {{- end }}
  {{- /* END IF Handle Role */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
