{{- /* library template for operator Subscription definition */}}
{{- /*
BEGVAL
# -- (dict) operator
# @default -- see subconfig
# DOC: [operator](https://docs.openshift.com/container-platform/4.12/operators/understanding/olm-what-operators-are.html)
operator:
  # -- Create OPERATOR subscription
  # @default -- see subconfig
  ## HELPER subscription AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,channel,installPlanApproval,operatorName,source,sourceNamespace
  subscription:
    -
      # -- (string)[REQ] name
      ## MUST BE metallb
      name: metallb
      # -- (string)[REQ] namespace
      namespace: metallb-system

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

      # -- (string)[REQ] channel
      channel: "stable"

      # -- (string)[REQ] installPlanApproval
      installPlanApproval: Manual

      # -- (string)[REQ] operatorName
      operatorName: metallb-operator

      # -- (string)[REQ] source
      source: redhat-operators

      # -- (string)[REQ] sourceNamespace
      sourceNamespace: openshift-marketplace

      # -- (string)[OPT] startingCSV
      startingCSV:

ENDVAL
*/}}
{{- define "sharedlibraries.operator_subscription" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if not $.Values.operator.subscription }}
    {{- fail "operator_group template loaded without operator.subscription object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "channel" "installPlanApproval" "operatorName" "source" "sourceNamespace" "startingCSV" ) }}

  {{- /*
  #################################
  LOOP all installplan instance
  #################################
  */}}
  {{- range $operatorSubscription := $.Values.operator.subscription }}
    {{- /* DEBUG include "sharedlibraries.dump" $operatorSubscription */}}
    {{- /*
    #################################
    CHECK mandatory operatorSubscription values
    #################################
    */}}
    {{- /* CHECK operatorSubscription.name */}}
    {{- if not $operatorSubscription.name }}
      {{- fail "no name set inside operator.subscription object" }}
    {{- end }}

    {{- /* CHECK operatorSubscription.namespace */}}
    {{- if not $operatorSubscription.namespace }}
      {{- fail "no namespace set inside operator.subscription object" }}
    {{- end }}

    {{- /* CHECK operatorSubscription.additionalLabels */}}
    {{- if and ( $operatorSubscription.additionalLabels ) ( not ( kindIs "map" $operatorSubscription.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside operator.subscription object but type is :%s" ( kindOf $operatorSubscription.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK operatorSubscription.additionalAnnotations */}}
    {{- if and ( $operatorSubscription.additionalAnnotations ) ( not ( kindIs "map" $operatorSubscription.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside operator.subscription object but type is :%s" ( kindOf $operatorSubscription.additionalAnnotations ) ) }}
    {{- end }}
    {{- /* CHECK operatorSubscription.channel */}}

    {{- if not $operatorSubscription.channel }}
      {{- fail "no channel set inside operator.subscription object" }}
    {{- end }}

    {{- /* CHECK operatorSubscription.installPlanApproval */}}
    {{- if not $operatorSubscription.installPlanApproval }}
      {{- fail "no installPlanApproval set inside operator.subscription object" }}
    {{- end }}

    {{- /* CHECK operatorSubscription.operatorName */}}
    {{- if not $operatorSubscription.operatorName }}
      {{- fail "no operatorName set inside operator.subscription object" }}
    {{- end }}

    {{- /* CHECK operatorSubscription.source */}}
    {{- if not $operatorSubscription.source }}
      {{- fail "no source set inside operator.subscription object" }}
    {{- end }}

    {{- /* CHECK operatorSubscription.sourceNamespace */}}
    {{- if not $operatorSubscription.sourceNamespace }}
      {{- fail "no sourceNamespace set inside operator.subscription object" }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: {{ $operatorSubscription.name }}
  namespace: {{ $operatorSubscription.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $operatorSubscription.additionalLabels }}
{{ toYaml $operatorSubscription.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "01" $operatorSubscription.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $operatorSubscription.additionalAnnotations }}
{{ toYaml $operatorSubscription.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  channel: {{ $operatorSubscription.channel }}
  installPlanApproval: {{ $operatorSubscription.installPlanApproval }}
  name: {{ $operatorSubscription.operatorName }}
  source: {{ $operatorSubscription.source }}
  sourceNamespace: {{ $operatorSubscription.sourceNamespace }}
    {{- if $operatorSubscription.startingCSV }}
  startingCSV: {{ $operatorSubscription.startingCSV }}
    {{- end }}
    {{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $operatorSubscription }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $operatorSubscriptionAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $operatorSubscriptionAdditionnalInfos }}
{{ toYaml $operatorSubscriptionAdditionnalInfos | indent 2 }}
    {{- /* END IF $operatorSubscriptionAdditionnalInfos  */}}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
