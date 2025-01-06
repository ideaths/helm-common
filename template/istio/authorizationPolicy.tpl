# templates/istio/authorizationPolicy.tpl
{{- if .Values.istio.authorizationPolicy.enabled }}
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ include "yourchart.fullname" . }}-authz
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "yourchart.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  rules:
    - from:
        - source:
            principals:
              - "{{ .Values.istio.authorizationPolicy.principal }}"
{{- end }}
