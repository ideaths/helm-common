{{- define "common.role.tpl" -}}
{{- if and .Values.rbac.create (eq .Values.rbac.type "Role") }}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ .Values.rbac.name | default (include "common.fullname" .) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.rbac.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
rules:
{{- if .Values.rbac.rules }}
{{ toYaml .Values.rbac.rules | nindent 2 }}
{{- else }}
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
{{- end }}
{{- end }}
{{- end -}}