{{/* library template function check LIST type and mandatory value */}}
{{/* TESTED OK : 18/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################
  fromDict: dictionnary
  masterKey : key to verify
  baseKey : base object for message output
  mandatoryKeys : list
*/}}
{{- define "sharedlibraries.checkVariableList" -}}
  {{- $baseMessageObj := $.masterKey }}
  {{- if $.baseKey }}
    {{- $baseMessageObj = ( printf "%s.%s" $.baseKey $baseMessageObj ) }}
  {{- end }}
  {{- if not ( hasKey $.fromDict $.masterKey ) }}
    {{- fail ( printf "No %s set inside %s object" $.masterKey $baseMessageObj  ) }}
  {{- else }}
    {{- $currentStuff := get $.fromDict $.masterKey }}
    {{- if not ( kindIs "slice" $currentStuff ) }}
      {{- fail (printf "%s is not a LIST inside %s object but type is :%s" $.masterKey $baseMessageObj ( kindOf $currentStuff ) ) }}
    {{- else }}
      {{- range $currentListItem := $currentStuff }}
        {{- range $currentmandatoryKey := $.mandatoryKeys }}
          {{- if not ( hasKey $currentListItem $currentmandatoryKey ) }}
            {{- fail (printf "No %s set inside on of %s object " $currentmandatoryKey $baseMessageObj ) }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
