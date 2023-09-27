{{- /* library template for traefik serverstransport definition */}}
{{- /*
BEGVAL

# -- (dict) TRAEFIK definition
# @default -- see subconfig
# DOC: [traefik](https://doc.traefik.io/traefik/)
traefik:
  # -- Create TRAEFIK tlsoptions
  # @default -- see subconfig
  # DOC : [traefik serversTransport](https://doc.traefik.io/traefik/v2.9/routing/providers/kubernetes-crd/#kind-serverstransport)
  # DOC : [traefik serversTransport](https://doc.traefik.io/traefik/v2.9/routing/services/#serverstransport)
  ## HELPER TRAEFIK serversTransport AdditionnalInfos
  ## write as YAML (without formating or validation) everything except:
  ## name, namespace, additionalLabels, additionalAnnotations, syncWave
  serversTransport:
    -
      # -- (string)[REQ] name
      name: traefik-tlsoptions
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

      # -- (string)[OPT] serverName
      serverName: foobar
      # -- (bool)[OPT] insecureSkipVerify
      insecureSkipVerify: true
      # -- (list)[OPT] rootCAsSecrets
      rootCAsSecrets:
        - foobar
        - foobar
      # -- (list)[OPT] certificatesSecrets
      certificatesSecrets:
        - foobar
        - foobar
      # -- (int)[OPT] maxIdleConnsPerHost
      maxIdleConnsPerHost: 1
      # -- (dict)[OPT] forwardingTimeouts
      forwardingTimeouts:
        # -- (string)[OPT] dialTimeout
        dialTimeout: 42s
        # -- (string)[OPT] responseHeaderTimeout
        responseHeaderTimeout: 42s
        # -- (string)[OPT] idleConnTimeout
        idleConnTimeout: 42s
      # -- (string)[OPT] peerCertURI
      peerCertURI: foobar
      # -- (bool)[OPT] disableHTTP2
      disableHTTP2: true

ENDVAL
*/}}
{{- define "sharedlibraries.traefik_serverstransport" -}}
  {{- /* Validation GENERAL */}}
  {{- /*
  #################################
  CHECK mandatory global values
  #################################
  */}}

  {{- if and ( not $.Values.traefik ) }}
    {{- fail "traefik_serverstransport template loaded without traefik object" }}
  {{- end }}

  {{- if and (not $.Values.traefik.serversTransport ) }}
    {{- fail "traefik_serverstransport template loaded without traefik.serversTransport object" }}
  {{- end }}

  {{- /*
  #################################
  CREATE global avoid keys
  #################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabels" "additionalAnnotations" "syncWave" ) }}

  {{- /*
  #################################
  LOOP all serversTransport instance
  #################################
  */}}
  {{- range $serversTransport := $.Values.traefik.serversTransport }}
    {{- /* DEBUG include "sharedlibraries.dump" $serversTransport */}}
    {{- /*
    #################################
    CHECK mandatory serversTransport values
    #################################
    */}}
    {{- /* CHECK serversTransport.name */}}
    {{- if not $serversTransport.name }}
      {{- fail "No name set inside traefik.serversTransport object" }}
    {{- end }}

    {{- /* CHECK serversTransport.namespace */}}
    {{- if not $serversTransport.namespace }}
      {{- fail "No namespace set inside traefik.serversTransport object" }}
    {{- end }}

    {{- /* CHECK serversTransport.additionalLabels */}}
    {{- if and ( $serversTransport.additionalLabels ) ( not ( kindIs "map" $serversTransport.additionalLabels ) ) }}
      {{- fail ( printf "additionalLabels is not a DICT inside traefik.serversTransport object but type is :%s" ( kindOf $serversTransport.additionalLabels  ) ) }}
    {{- end }}

    {{- /* CHECK serversTransport.additionalAnnotations */}}
    {{- if and ( $serversTransport.additionalAnnotations) ( not ( kindIs "map" $serversTransport.additionalAnnotations ) ) }}
      {{- fail ( printf "additionalAnnotations is not a DICT inside traefik.serversTransport object but type is :%s" ( kindOf $serversTransport.additionalAnnotations  ) ) }}
    {{- end }}

{{- /* TEMPLATE */}}
---
apiVersion: traefik.io/v1alpha1
kind: ServersTransport
metadata:
  name: {{ $serversTransport.name }}
  namespace: {{ $serversTransport.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $serversTransport.additionalLabels }}
{{ toYaml $serversTransport.additionalLabels | indent 4 }}
    {{- /* END IF serverstransport.additionalLabels */}}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $serversTransport.syncWave | squote }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $serversTransport.additionalAnnotations }}
{{ toYaml $serversTransport.additionalAnnotations | indent 4 }}
    {{- /* END IF serverstransport.additionalAnnotations */}}
    {{- end }}
spec:
    {{- $parameterserverstransport := dict }}
    {{- $_ := set $parameterserverstransport "fromDict" $serversTransport }}
    {{- $_ := set $parameterserverstransport "avoidList" $avoidKeys }}
    {{- $serversTransportAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameterserverstransport ) }}
    {{- if $serversTransportAdditionnalInfos }}
{{ toYaml $serversTransportAdditionnalInfos | indent 2 }}
    {{- /* END IF serverstransportAdditionnalInfos */}}
    {{- end }}
...
  {{- /* END RANGE serverstransport */}}
  {{- end }}
{{- /* END DEFINE */}}
{{- end -}}
