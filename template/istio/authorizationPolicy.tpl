{{- define "common.istio.authorizationPolicy.tpl" -}}
{{- if .Values.istio.authorizationPolicy.enabled }}
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ include "common.fullname" . }}-authz
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  rules:
    - from:
        - source:
            principals:
              - "{{ .Values.istio.authorizationPolicy.principal }}"
{{- end }}
{{- end -}}
