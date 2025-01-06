{{- if .Values.secret.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "yourchart.fullname" . }}-secret
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
type: Opaque
data:
  {{- range $key, $value := .Values.secret.data }}
  {{ $key }}: {{ $value | b64enc }}
  {{- end }}
{{- end }}
