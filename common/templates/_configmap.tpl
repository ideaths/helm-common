{{- define "common.configmap.tpl" -}}
{{- if .Values.configmap.create }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.configmap.name | default (printf "%s-config" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.configmap.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
data:
  {{- if .Values.configmap.serverConfigFiles }}
  {{- range $key, $file := .Values.configmap.serverConfigFiles }}
  {{ $key }}: |
    {{- (.Files.Get $file) | nindent 4 }}
  {{- end }}
  {{- end }}
  
  {{- if .Values.configmap.vars }}
  {{- range $key, $value := .Values.configmap.vars }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
  {{- end }}
  
  {{- if .Values.configmap.data }}
  {{- toYaml .Values.configmap.data | nindent 2 }}
  {{- end }}
{{- end }}
{{- end -}}