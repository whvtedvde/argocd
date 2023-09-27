{{/* library template for  Variable DUMP */}}
{{/* TESTED OK : 17/02/2023 */}}
{{- define "sharedlibraries.dump" -}}
{{/* . | mustToPrettyJson | printf "%s" */}}
{{- . | toJson | printf "%s" }}
{{- end -}}
