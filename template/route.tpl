{{- define "common.route.tpl" -}}
{{- if .Values.route.enabled }}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ .Values.route.name | default (include "common.fullname" .) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.route.host }}
  host: {{ .Values.route.host }}
  {{- end }}
  to:
    kind: {{ .Values.route.to.kind | default "Service" }}
    name: {{ .Values.route.to.name | default (include "common.fullname" .) }}
    weight: {{ .Values.route.to.weight | default 100 }}
  {{- if .Values.route.alternateBackends }}
  alternateBackends:
    {{- range .Values.route.alternateBackends }}
    - kind: {{ .kind | default "Service" }}
      name: {{ .name }}
      weight: {{ .weight | default 0 }}
    {{- end }}
  {{- end }}
  port:
    targetPort: {{ .Values.route.targetPort | default .Values.service.targetPort | default "http" }}
  {{- if .Values.route.path }}
  path: {{ .Values.route.path }}
  {{- end }}
  {{- if .Values.route.wildcardPolicy }}
  wildcardPolicy: {{ .Values.route.wildcardPolicy }}
  {{- end }}
  {{- if .Values.route.tls }}
  tls:
    termination: {{ .Values.route.tls.termination }}
    {{- if .Values.route.tls.insecureEdgeTerminationPolicy }}
    insecureEdgeTerminationPolicy: {{ .Values.route.tls.insecureEdgeTerminationPolicy }}
    {{- end }}
    {{- if .Values.route.tls.key }}
    key: {{ .Values.route.tls.key | quote }}
    {{- end }}
    {{- if .Values.route.tls.certificate }}
    certificate: {{ .Values.route.tls.certificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.caCertificate }}
    caCertificate: {{ .Values.route.tls.caCertificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.destinationCACertificate }}
    destinationCACertificate: {{ .Values.route.tls.destinationCACertificate | quote }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}