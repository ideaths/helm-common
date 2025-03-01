{{- define "common.serviceaccount.tpl" -}}
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "common.serviceAccountName" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if .Values.serviceAccount.automountServiceAccountToken }}
  automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
  {{- end }}
{{- if .Values.serviceAccount.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.serviceAccount.imagePullSecrets }}
  - name: {{ . }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}