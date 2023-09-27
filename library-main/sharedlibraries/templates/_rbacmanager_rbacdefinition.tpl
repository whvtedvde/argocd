{{- /* library template for  rbacmanager RBAC definition*/}}
{{- /* Parametre / Values
BEGVAL
# -- (dict) RBAC definition
# @default -- see subconfig
# DOC: [RBAC](https://rbac-manager.docs.fairwinds.com/rbacdefinitions/)
rbacmanager:
  # -- (list) definition
  definition:
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

      # -- (list)[REQ] rbacBindings
      ## HELPER rules AdditionnalInfos
      ## write as yaml with validation
      rbacBindings:
  # -- (string)[REQ] name
        name: "cr-test"
  # -- (list)[REQ] subjects
        subjects:
   -
     # -- (string)[REQ] kind
     ## user, group, serviceaccount
     kind: Group

     # -- (string)[REQ] name
     ## name of user, group, serviceaccount
     name: PAPF_OPENSHIFT-SUPPORT

     # -- (string)[OPT] namespace
     namespace: rbac-manager

    # -- (list)[REQ] roleBindings
  ## need roleBindings or clusterRoleBindings
        roleBindings:
   -
     # -- (string)[REQ] clusterRole
     clusterRole: support-role-prp

     # -- (string)[REQ] namespace
     ## need namespace or namespaceselector
     namespace: rbac-manager

       # -- (dict)[REQ] namespaceSelector
           ## All of the requirements, from both matchLabels and matchExpressions are ANDed together
           ## they must all be satisfied in order to match.
           namespaceSelector:

             # -- (dict)[REQ] namespace labels with matchLabels
             matchLabels:

              # -- (string)[REQ] namespace labels example
              kubernetes.io/metadata.name: outils

             # -- (list)[REQ] namespace labels with matchExpressions
             matchExpressions:
              - key: 620nm.net/rbac
                operator: In
                values:
                  - dmz
                  - backend

    # -- (list)[REQ] clusterRoleBindings
  ## need roleBindings or clusterRoleBindings
        clusterRoleBindings:
   -
     # -- (string)[REQ] clusterRole
     clusterRole: support-clusterrole-prp

ENDVAL

*/}}
{{- define "sharedlibraries.rbacmanager_rbacdefinition" -}}
  {{- /* Validation GENERAL */}}
  {{- /*  CHECK mandatory global values  */}}

  {{- if and (not $.Values.rbacmanager) }}
    {{- fail "rbacmanager_rbacdefinition template loaded without rbacmanager object" }}
  {{- end }}

  {{- if and (not $.Values.rbacmanager.definition ) }}
    {{- fail "rbacmanager_rbacdefinition template loaded without rbacmanager.definition object" }}
  {{- end }}

    {{- /*  LOOP all connection instance */}}
  {{- range $definition := $.Values.rbacmanager.definition }}
    {{- /* DEBUG include "sharedlibraries.dump" $definition */}}
    {{- /* CHECK mandatory definition values */}}
    {{- /* CHECK definition.name */}}
    {{- if not $definition.name }}
      {{- fail "No name set inside rbacmanager.definition object" }}
    {{- end }}

    {{- /* CHECK definition.additionalLabels */}}
    {{- if and ( $definition.additionalLabels ) ( not ( kindIs "map" $definition.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside rbacmanager.definition object but type is :%s" ( kindOf $definition.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK definition.additionalAnnotations */}}
    {{- if and ( $definition.additionalAnnotations) ( not ( kindIs "map" $definition.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside rbacmanager.definition object but type is :%s" ( kindOf $definition.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK definition.rbacBindings */}}
    {{- if or ( not $definition.rbacBindings ) ( not ( kindIs "slice" $definition.rbacBindings ) ) }}
      {{- fail ( printf "rbacBindings is not a list inside rbacmanager.definition object but type is :%s" ( kindOf $definition.rbacBindings ) ) }}
    {{- end }}

    {{- /* CHECK KIND and MANDATORY definition.rbacBindings */}}
    {{- $parameterCheckdefinitionRbacBindings := dict }}
    {{- $parameterCheckDictdefinitionRbacBindingsMandatoryKeys := ( list "subjects" "name" ) }}
    {{- $_ := set $parameterCheckdefinitionRbacBindings "fromDict" $definition }}
    {{- $_ := set $parameterCheckdefinitionRbacBindings "masterKey" "rbacBindings" }}
    {{- $_ := set $parameterCheckdefinitionRbacBindings "baseKey" "rbacmanager.definition" }}
    {{- $_ := set $parameterCheckdefinitionRbacBindings "mandatoryKeys" $parameterCheckDictdefinitionRbacBindingsMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckdefinitionRbacBindings }}

{{- /* TEMPLATE */}}
---
apiVersion: rbacmanager.reactiveops.io/v1beta1
kind: RBACDefinition
metadata:
  name: {{ $definition.name }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $definition.additionalLabels}}
{{ toYaml $definition.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "-1" $definition.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $definition.additionalAnnotations }}
{{ toYaml $definition.additionalAnnotations | indent 4 }}
    {{- end }}
rbacBindings:
    {{- range $rbacBinding := $definition.rbacBindings }}
  -
    name: {{ $rbacBinding.name }}
    subjects:
      {{- /* CHECK KIND and MANDATORY RbacBindingSubject */}}
      {{- $parameterCheckDictRbacBindingSubjectRules := dict }}
      {{- $parameterCheckDictRbacBindingSubjectMandatoryKeys := ( list "kind" "name" ) }}
      {{- $_ := set $parameterCheckDictRbacBindingSubjectRules "fromDict" $rbacBinding }}
      {{- $_ := set $parameterCheckDictRbacBindingSubjectRules "masterKey" "subjects" }}
      {{- $_ := set $parameterCheckDictRbacBindingSubjectRules "baseKey" "rbacmanager.definition.rbacBindings" }}
      {{- $_ := set $parameterCheckDictRbacBindingSubjectRules "mandatoryKeys" $parameterCheckDictRbacBindingSubjectMandatoryKeys }}
      {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRbacBindingSubjectRules }}
{{ toYaml $rbacBinding.subjects | indent 6 }}
      {{- if and ( not $rbacBinding.clusterRoleBindings ) ( not $rbacBinding.roleBindings ) }}
      {{- fail ( printf "rbacBindings clusterRoleBindings or roleBindings is not set") }}
      {{- end }}

      {{- if and (  $rbacBinding.clusterRoleBindings ) }}
        {{- /* CHECK KIND and MANDATORY RbacBindingclusterRoleBindings */}}
        {{- $parameterCheckDictRbacBindingclusterRoleBindingsRules := dict }}
        {{- $parameterCheckDictRbacBindingclusterRoleBindingsMandatoryKeys := ( list "clusterRole" ) }}
        {{- $_ := set $parameterCheckDictRbacBindingclusterRoleBindingsRules "fromDict" $rbacBinding }}
        {{- $_ := set $parameterCheckDictRbacBindingclusterRoleBindingsRules "masterKey" "clusterRoleBindings" }}
        {{- $_ := set $parameterCheckDictRbacBindingclusterRoleBindingsRules "baseKey" "rbacmanager.definition.rbacBindings" }}
        {{- $_ := set $parameterCheckDictRbacBindingclusterRoleBindingsRules "mandatoryKeys" $parameterCheckDictRbacBindingclusterRoleBindingsMandatoryKeys  }}
        {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRbacBindingclusterRoleBindingsRules }}
    clusterRoleBindings:
{{ toYaml $rbacBinding.clusterRoleBindings | indent 6 }}
      {{- end }}

      {{- if and (  $rbacBinding.roleBindings ) }}
        {{- /* CHECK KIND and MANDATORY RbacBindingRoleBindings */}}
        {{- $parameterCheckDictRbacBindingRoleBindingsRules := dict }}
        {{- $parameterCheckDictRbacBindingRoleBindingsMandatoryKeys := ( list "clusterRole"  ) }}
        {{- $_ := set $parameterCheckDictRbacBindingRoleBindingsRules "fromDict" $rbacBinding }}
        {{- $_ := set $parameterCheckDictRbacBindingRoleBindingsRules "masterKey" "roleBindings" }}
        {{- $_ := set $parameterCheckDictRbacBindingRoleBindingsRules "baseKey" "rbacmanager.definition.rbacBindings" }}
        {{- $_ := set $parameterCheckDictRbacBindingRoleBindingsRules "mandatoryKeys" $parameterCheckDictRbacBindingRoleBindingsMandatoryKeys  }}
        {{- include "sharedlibraries.checkVariableList" $parameterCheckDictRbacBindingRoleBindingsRules }}
    roleBindings:
{{ toYaml $rbacBinding.roleBindings | indent 6 }}
      {{- end }}

    {{- /* END RANGE rbacBinding */}}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
