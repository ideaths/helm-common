{{- define "common.istio.authorizationPolicy.tpl" -}}
{{- if .Values.istio.authorizationPolicy.enabled }}
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ .Values.istio.authorizationPolicy.name | default (printf "%s-authz" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.istio.authorizationPolicy.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.istio.authorizationPolicy.selector }}
  selector:
    matchLabels:
      {{- toYaml .Values.istio.authorizationPolicy.selector | nindent 6 }}
  {{- else }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  {{- end }}
  
  {{- if .Values.istio.authorizationPolicy.action }}
  action: {{ .Values.istio.authorizationPolicy.action }}
  {{- end }}
  
  {{- if or .Values.istio.authorizationPolicy.rules .Values.istio.authorizationPolicy.principal }}
  rules:
    {{- if .Values.istio.authorizationPolicy.rules }}
    {{- toYaml .Values.istio.authorizationPolicy.rules | nindent 4 }}
    {{- else }}
    - from:
        - source:
            principals:
              - "{{ .Values.istio.authorizationPolicy.principal }}"
      {{- if .Values.istio.authorizationPolicy.paths }}
      to:
        - operation:
            paths:
              {{- range .Values.istio.authorizationPolicy.paths }}
              - {{ . }}
              {{- end }}
      {{- end }}
      {{- if .Values.istio.authorizationPolicy.methods }}
      to:
        - operation:
            methods:
              {{- range .Values.istio.authorizationPolicy.methods }}
              - {{ . }}
              {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}