{{- /* library template for services definition */}}
{{- /*
BEGVAL
# -- (dict) services
# @default -- see subconfig
# DOC: [services](https://kubernetes.io/fr/docs/concepts/services-networking/service/)
# DOC: [services](https://docs.openshift.com/online/pro/architecture/core_concepts/pods_and_services.html#services)
services:
  # -- Create services
  # @default -- see subconfig
  # DOC: [services](https://kubernetes.io/fr/docs/concepts/services-networking/service/)
  ## HELPER services AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave, type , ports
  -
    # -- (string)[REQ] name
    name: svc-test-clusterip
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
    syncWave: 04

    # -- (string)[REQ] type
    ## Can be ClusterIP / LoadBalancer / etc
    type: ClusterIP

    # -- (list)[REQ] ports
    ## HELPER services AdditionnalInfos
    ## write as YAML (without formating or validation) everything except:
    ## name, namespace, additionalLabels, additionalAnnotations, syncWave, type , ports
    ports:
      -
        # -- (int)[REQ] port
        port: 3306
        # -- (string)[OPT] name
        name: mariadb
        # -- (string)[OPT] protocol
        protocol: TCP
        # -- (int)[OPT] targetPort
        targetPort: 3306


  -
    # -- (string)[REQ] name
    name: svc-test-loadbalancer
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
    syncWave: 04

    # -- (string)[REQ] type
    ## Can be ClusterIP / LoadBalancer / etc
    type: LoadBalancer

    # -- (list)[REQ] ports
    ## HELPER services AdditionnalInfos
    ## write as YAML (without formating or validation) everything except:
    ## name, namespace, additionalLabels, additionalAnnotations, syncWave, type , ports
    ports:
      -
        # -- (int)[REQ] port
        port: 80
        # -- (string)[OPT] name
        name: web
        # -- (string)[OPT] protocol
        protocol: TCP
        # -- (int)[OPT] targetPort
        targetPort: 8080
        # -- (int)[OPT] nodePort
        nodePort: 30323
      -
        # -- (int)[REQ] port
        port: 443
        # -- (string)[OPT] name
        name: websecure
        # -- (string)[OPT] protocol
        protocol: TCP
        # -- (int)[OPT] targetPort
        targetPort: 8443
        # -- (int)[OPT] nodePort
        nodePort: 30323

    # -- (string)[OPT] externalTrafficPolicy
    externalTrafficPolicy: Local
    # -- (dict)[OPT] selector
    selector:
      app.kubernetes.io/instance: traefik-outils-dmz-outils-dmz
      app.kubernetes.io/name: traefik

ENDVAL
*/}}
{{- define "sharedlibraries.services" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if not $.Values.services }}
    {{- fail "services template loaded without services object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := ( list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" "ports" "type" ) }}

  {{- /*
  #################################
  LOOP all installplan instance
  #################################
  */}}
  {{- range $services := $.Values.services }}
    {{- /* DEBUG include "sharedlibraries.dump" $services */}}

    {{- /*
    #################################
    CHECK mandatory services values
    #################################
    */}}

    {{- /* CHECK services.name */}}
    {{- if not $services.name }}
      {{- fail "no name set inside services object" }}
    {{- end }}

    {{- /* CHECK services.namespace */}}
    {{- if not $services.namespace }}
      {{- fail "no namespace set inside services object" }}
    {{- end }}

    {{- /* CHECK services.additionalLabels */}}
    {{- if and ( $services.additionalLabels ) ( not ( kindIs "map" $services.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside services object but type is :%s" ( kindOf $services.additionalLabels ) ) }}
    {{- end }}

    {{- /* CHECK services.additionalAnnotations */}}
    {{- if and ( $services.additionalAnnotations ) ( not ( kindIs "map" $services.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside services object but type is :%s" ( kindOf $services.additionalAnnotations ) ) }}
    {{- end }}

    {{- /* CHECK parameterCheckDictServicePorts */}}
    {{- $parameterCheckDictServicePorts := dict }}
    {{- $parameterCheckDictServicePortsMandatoryKeys := ( list "port" ) }}
    {{- $_ := set $parameterCheckDictServicePorts "fromDict" $services }}
    {{- $_ := set $parameterCheckDictServicePorts "masterKey" "ports" }}
    {{- $_ := set $parameterCheckDictServicePorts "baseKey" "services" }}
    {{- $_ := set $parameterCheckDictServicePorts "mandatoryKeys" $parameterCheckDictServicePortsMandatoryKeys }}
    {{- include "sharedlibraries.checkVariableList" $parameterCheckDictServicePorts }}

    {{- /* CHECK services.name */}}
    {{- if not $services.type }}
      {{- fail "No type set inside services object" }}
    {{- end }}

{{- /* TEMPLATE */}}
---
kind: Service
apiVersion: v1
metadata:
  name: {{ $services.name }}
  namespace: {{ $services.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $services.additionalLabels }}
{{ toYaml $services.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $services.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $services.additionalAnnotations }}
{{ toYaml $services.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  type: {{ $services.type | default "ClusterIP" }}
  ports: {{ toYaml $services.ports | nindent 4 }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $services }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $servicesAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $servicesAdditionnalInfos }}
{{ toYaml $servicesAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{- /* END RANGE */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
