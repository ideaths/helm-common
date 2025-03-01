{{- define "common.secret.tpl" -}}
{{- if .Values.secret.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Values.secret.name | default (printf "%s-secret" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.secret.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
type: {{ .Values.secret.type | default "Opaque" }}
{{- if .Values.secret.stringData }}
stringData:
  {{- range $key, $value := .Values.secret.stringData }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
{{- end }}
{{- if .Values.secret.data }}
data:
  {{- range $key, $value := .Values.secret.data }}
  {{ $key }}: {{ $value | b64enc }}
  {{- end }}
{{- end }}
{{- if .Values.secret.dataFromFile }}
data:
  {{- range $key, $file := .Values.secret.dataFromFile }}
  {{ $key }}: {{ $.Files.Get $file | b64enc }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}