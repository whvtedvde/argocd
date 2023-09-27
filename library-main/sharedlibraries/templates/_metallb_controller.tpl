{{- /* library template for MetalLB controller definition */}}
{{- /*
BEGVAL
# -- (dict) metalLB
# @default -- see subconfig
# DOC: [metalLB](https://metallb.universe.tf/)
metalLB:
  # -- Create METALLB controller
  # @default -- see subconfig
  ## HELPER installplan AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  controller:
    -
      # -- (string)[REQ] name
      # @default -- metallb
      name: metallb
      # -- (string)[REQ] namespace
      # @default -- metallb-system
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
      syncWave: 03
ENDVAL
*/}}
{{- define "sharedlibraries.metallb_controller" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
	#################################
	CHECK mandatory global values
	#################################
	*/}}
  {{- if and ( not $.Values.metalLB ) }}
    {{- fail "metallb_controller template loaded without metalLB object" }}
  {{- end }}

  {{- if and ( not $.Values.metalLB ) }}
    {{- fail "metallb_controller template loaded without metalLB.controller object" }}
  {{- end }}

	{{- /*
	#################################
	CREATE global avoid keys
	#################################
	*/}}
	{{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave") }}

	{{- /*
	#################################
	LOOP all controller instance
	#################################
	*/}}
  {{- range $controller := $.Values.metalLB.controller }}
    {{- /* DEBUG include "sharedlibraries.dump" $controller */}}
    {{- /*
		#################################
		CHECK mandatory controller values
		#################################
		*/}}
    {{- /* CHECK controller.name */}}
    {{- if not $controller.name }}
      {{- fail "No name set inside metalLB.controller object" }}
    {{- end }}

    {{- /* CHECK controller.namespace */}}
    {{- if not $controller.namespace }}
      {{- fail "No namespace set inside metalLB.controller object" }}
    {{- end }}

    {{- /* CHECK KIND controller.additionalLabels */}}
    {{- if and ( $controller.additionalLabels) ( not ( kindIs "map" $controller.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside metalLB.controller object but type is :%s" ( kindOf $controller.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK KIND controller.additionalAnnotations */}}
    {{- if and ( $controller.additionalAnnotations) ( not ( kindIs "map" $controller.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside metalLB.controller object but type is :%s" ( kindOf $controller.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK KIND $controller.additionalAnnotations */}}
    {{- if and ( $controller.additionalAnnotations) ( not ( kindIs "map" $controller.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside metalLB.controller object but type is :%s" ( kindOf $controller.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK CRD
    {{- if not ( $.Capabilities.APIVersions.Has "metallb.io/v1beta1" ) }}
      {{- fail ( printf "Our cluster don't have MetalLB CRD :metallb.io/v1beta1" ) }}
    {{- end }}
		*/}}

{{- /* TEMPLATE */}}
---
kind: MetalLB
apiVersion: metallb.io/v1beta1
metadata:
  name: {{ $controller.name }}
  namespace: {{ $controller.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $controller.additionalLabels }}
{{ toYaml $controller.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "03" $controller.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $controller.additionalAnnotations }}
{{ toYaml $controller.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
		{{- /* Template ALL values except avoidKeys */}}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $controller }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $controllerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $controllerAdditionnalInfos }}
{{ toYaml $controllerAdditionnalInfos | indent 2 }}
    {{- /* END IF $controllerAdditionnalInfos  */}}
    {{- end }}
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
