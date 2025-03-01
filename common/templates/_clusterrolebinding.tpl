{{- define "common.clusterrolebinding.tpl" -}}
{{- if and .Values.rbac.create (eq .Values.rbac.type "ClusterRole") }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ .Values.rbac.name | default (printf "%s-%s" .Release.Namespace (include "common.fullname" .)) }}
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
  kind: ClusterRole
  name: {{ .Values.rbac.name | default (printf "%s-%s" .Release.Namespace (include "common.fullname" .)) }}
{{- end }}
{{- end -}}