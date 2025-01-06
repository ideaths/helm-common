# templates/common/route.tpl
{{- if .Values.route.enabled }}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ include "yourchart.fullname" . }}
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
  annotations:
    {{- toYaml .Values.route.annotations | nindent 4 }}
spec:
  host: {{ .Values.route.host }}
  to:
    kind: Service
    name: {{ include "yourchart.fullname" . }}
  port:
    targetPort: {{ .Values.service.targetPort }}
  tls:
    termination: {{ .Values.route.tls.termination }}
    insecureEdgeTerminationPolicy: {{ .Values.route.tls.insecureEdgeTerminationPolicy }}
    key: {{ .Values.route.tls.key | quote }}
    certificate: {{ .Values.route.tls.certificate | quote }}
    caCertificate: {{ .Values.route.tls.caCertificate | quote }}
{{- end }}
