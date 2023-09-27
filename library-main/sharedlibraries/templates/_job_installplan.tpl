{{- /* library template for job Installplan definition */}}
{{- /*
BEGVAL
# -- (dict) job
# @default -- see subconfig
# DOC:
job:
  # -- Create OPERATOR job installplan
  # @default -- see subconfig
  ## HELPER installplan AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave,template
  installplan:
    -
      # -- (string)[REQ] name
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
      syncWave: 01

      # -- (string)[REQ] operatorName
      ## use to search subscription
      operatorName: metallb

      template:
        # -- (dict)[OPT] template.spec
        # HELPER template.spec AdditionnalInfos
        # write as YAML (without formating or validation) everything
        spec:
          # -- (string)[OPT] dnsPolicy
          dnsPolicy: ClusterFirst
          # -- (string)[OPT] restartPolicy
          restartPolicy: OnFailure
          # -- (int)[OPT] terminationGracePeriodSeconds
          terminationGracePeriodSeconds: 30
          # -- (string)[OPT] serviceAccount
          serviceAccount: sa-installplan-approver
ENDVAL
*/}}
{{- define "sharedlibraries.job_installplan" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if not $.Values.job.installplan }}
    {{- fail "operator_group template loaded without job.installplan object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "operatorName" "template" ) }}

  {{- /*
  #################################
  LOOP all installplan instance
  #################################
  */}}
  {{- range $jobInstallplan := $.Values.job.installplan }}
    {{- /* DEBUG include "sharedlibraries.dump" $jobInstallplan */}}
    {{- /*
    #################################
    CHECK mandatory installplan values
    #################################
    */}}
    {{- /* CHECK installplan.name */}}
    {{- if not $jobInstallplan.name }}
      {{- fail "no name set inside job.installplan object" }}
    {{- end }}

    {{- /* CHECK installplan.namespace */}}
    {{- if not $jobInstallplan.namespace }}
      {{- fail "no namespace set inside job.installplan object" }}
    {{- end }}

    {{- /* CHECK installplan.additionalLabels */}}
    {{- if and ( $jobInstallplan.additionalLabels ) ( not ( kindIs "map" $jobInstallplan.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside job.installplan object but type is :%s" ( kindOf $jobInstallplan.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK installplan.additionalAnnotations */}}
    {{- if and ( $jobInstallplan.additionalAnnotations) ( not ( kindIs "map" $jobInstallplan.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside job.installplan object but type is :%s" ( kindOf $jobInstallplan.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK installplan.operatorName */}}
    {{- if not $jobInstallplan.operatorName }}
      {{- fail "no operatorName set inside job.installplan object" }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ $jobInstallplan.name }}
  namespace: {{ $jobInstallplan.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $jobInstallplan.additionalLabels }}
{{ toYaml $jobInstallplan.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "01" $jobInstallplan.syncWave | squote  }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $jobInstallplan.additionalAnnotations }}
{{ toYaml $jobInstallplan.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
    {{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $jobInstallplan }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $jobInstallplanAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $jobInstallplanAdditionnalInfos }}
{{ toYaml $jobInstallplanAdditionnalInfos | indent 2 }}
    {{- /* END IF $jobInstallplanAdditionnalInfos  */}}
    {{- end }}
  template:
    spec:
      containers:
        - image: registry.redhat.io/openshift4/ose-cli:v4.4
          env:
            - name: operatorName
              value: {{ $jobInstallplan.operatorName }}
            - name: operatorNamespace
              value: {{ $jobInstallplan.namespace }}
          command:
            - /bin/bash
            - -c
            - |
              export HOME=/tmp/approver
              echo "Approving operator InstallPlans.  Waiting a few seconds to make sure the InstallPlan gets created first."
              sleep 10
              echo "Trying to get subscription for $operatorName in NS $operatorNamespace "
              echo "Found those subscription: "
              subscription=$(oc get subscription.operators.coreos.com -n $operatorNamespace -o name | grep $operatorName )
              printf '%s\n' "${subscription[@]}"
              for subscription in `oc get subscription.operators.coreos.com -n $operatorNamespace -o name | grep $operatorName`
              do
                until [ "$(oc get $subscription -n $operatorNamespace -o jsonpath="{.status.installPlanRef.name}")" != "" ]; do sleep 2; done
                installplan=$(oc get $subscription -n $operatorNamespace -o jsonpath="{.status.installPlanRef.name}")
                if [ "`oc get installplan.operators.coreos.com -n $operatorNamespace $installplan -o jsonpath="{.spec.approved}"`" == "false" ]; then
                  echo "Approving Subscription $subscription with install plan $installplan"
                  oc patch installplan.operators.coreos.com -n $operatorNamespace $installplan --type=json -p='[{"op":"replace","path": "/spec/approved", "value": true}]'
                else
                  echo "Install Plan '$installplan' already approved"
                fi
              done
          imagePullPolicy: Always
          name: installplan-approver
    {{- if and $jobInstallplan.template $jobInstallplan.template.spec }}
      {{- $avoidKeysTemplateSpec := list }}
      {{- $parameterTemplateSpec := dict }}
      {{- $_ := set $parameterTemplateSpec "fromDict" $jobInstallplan.template.spec }}
      {{- $_ := set $parameterTemplateSpec "avoidList" $avoidKeysTemplateSpec }}
      {{- $jobInstallplanTemplateSpecAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterTemplateSpec ) }}
      {{- if $jobInstallplanTemplateSpecAdditionnalInfos }}
{{ toYaml $jobInstallplanTemplateSpecAdditionnalInfos | indent 6 }}
      {{- /* END IF $jobInstallplanTemplateSpecAdditionnalInfos  */}}
      {{- end }}
    {{- /* END IF $jobInstallplan.template $jobInstallplan.template.specs  */}}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
