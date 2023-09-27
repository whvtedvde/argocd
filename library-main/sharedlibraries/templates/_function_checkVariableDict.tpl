{{/* library template function check DICT type and mandatory value */}}
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
{{- define "sharedlibraries.checkVariableDict" -}}
  {{- $baseMessageObj := $.masterKey }}
	{{- if $.baseKey }}
		{{- $baseMessageObj = ( printf "%s.%s" $.baseKey $baseMessageObj ) }}
	{{- end }}
	{{- if not ( hasKey $.fromDict $.masterKey ) }}
    {{- fail ( printf "No %s set inside %s object" $.masterKey $baseMessageObj  ) }}
  {{- else }}
		{{- $currentStuff := get $.fromDict $.masterKey }}
		{{- if not ( kindIs "map" $currentStuff ) }}
		  {{- fail (printf "%s is not a DICT inside %s object but type is :%s" $.masterKey $baseMessageObj ( kindOf $currentStuff ) ) }}
		{{- else }}
      {{- range $currentmandatoryKey := $.mandatoryKeys }}
				{{- if not ( hasKey $currentStuff $currentmandatoryKey ) }}
					{{- fail (printf "No %s set inside %s object " $currentmandatoryKey $baseMessageObj ) }}
				{{- end }}
			{{- end }}
		{{- end }}
	{{- end }}
{{- end }}
