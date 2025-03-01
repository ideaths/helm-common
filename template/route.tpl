{{- define "common.route.tpl" -}}
{{- if .Values.route.enabled }}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  host: {{ .Values.route.host }}
  to:
    kind: Service
    name: {{ include "common.fullname" . }}
  port:
    targetPort: {{ .Values.service.targetPort }}
  {{- with .Values.route.tls }}
  tls:
    termination: {{ .termination }}
    insecureEdgeTerminationPolicy: {{ .insecureEdgeTerminationPolicy }}
    key: {{ .key | quote }}
    certificate: {{ .certificate | quote }}
    caCertificate: {{ .caCertificate | quote }}
  {{- end }}
{{- end }}
{{- end -}}
