{{/* library template function remove LIST of keys from DICT */}}
{{/* TESTED OK : 18/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################
  fromDict: dictionnary
  avoidList: list of key to remove from DICT
*/}}
{{- define "sharedlibraries.removeListOfKeysFromDict" -}}
  {{- $new := dict }}
  {{- range $key, $value := $.fromDict }}
    {{- if not ( has $key $.avoidList ) }}
      {{- $new = dict $key $value | merge $new }}
    {{- end }}
  {{- end }}
  {{- $new | toYaml }}
{{- end -}}
