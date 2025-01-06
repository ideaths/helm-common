{{- if and .Values.configmap.create .Values.configmap.serverConfigFiles }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "yourchart.fullname" . }}-config
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
data:
  {{- range $key, $file := .Values.configmap.serverConfigFiles }}
  {{ $key }}: |
    {{- (.Files.Get $file) | nindent 4 }}
  {{- end }}
  {{- if .Values.configmap.vars }}
  {{- range $key, $value := .Values.configmap.vars }}
  {{ $key }}: "{{ $value }}"
  {{- end }}
  {{- end }}
{{- end }}
