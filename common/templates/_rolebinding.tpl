{{- define "common.rolebinding.tpl" -}}
{{- if and .Values.rbac.create (eq .Values.rbac.type "Role") }}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ .Values.rbac.name | default (include "common.fullname" .) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.rbac.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
subjects:
{{- if .Values.rbac.subjects }}
{{ toYaml .Values.rbac.subjects | nindent 2 }}
{{- else }}
  - kind: ServiceAccount
    name: {{ include "common.serviceAccountName" . }}
    namespace: {{ .Release.Namespace }}
{{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ .Values.rbac.name | default (include "common.fullname" .) }}
{{- end }}
{{- end -}}