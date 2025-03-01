{{- define "common.istio.gateway.tpl" -}}
{{- if .Values.istio.gateway.enabled }}
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: {{ .Values.istio.gateway.name | default (printf "%s-gateway" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.istio.gateway.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  selector:
    {{- if .Values.istio.gateway.selector }}
    {{- toYaml .Values.istio.gateway.selector | nindent 4 }}
    {{- else }}
    istio: ingressgateway
    {{- end }}
  servers:
    {{- if .Values.istio.gateway.servers }}
    {{- toYaml .Values.istio.gateway.servers | nindent 4 }}
    {{- else }}
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        {{- if .Values.istio.gateway.hosts }}
        {{- range .Values.istio.gateway.hosts }}
        - {{ . | quote }}
        {{- end }}
        {{- else }}
        - {{ .Values.istio.gateway.host | default "*" | quote }}
        {{- end }}
      {{- if .Values.istio.gateway.httpRedirect }}
      tls: {}
      {{- end }}
    {{- if .Values.istio.gateway.enableHttps }}
    - port:
        number: 443
        name: https
        protocol: HTTPS
      hosts:
        {{- if .Values.istio.gateway.hosts }}
        {{- range .Values.istio.gateway.hosts }}
        - {{ . | quote }}
        {{- end }}
        {{- else }}
        - {{ .Values.istio.gateway.host | default "*" | quote }}
        {{- end }}
      tls:
        mode: {{ .Values.istio.gateway.tlsMode | default "SIMPLE" }}
        {{- if eq (.Values.istio.gateway.tlsMode | default "SIMPLE") "SIMPLE" }}
        credentialName: {{ .Values.istio.gateway.credentialName }}
        {{- end }}
        {{- if eq (.Values.istio.gateway.tlsMode | default "SIMPLE") "MUTUAL" }}
        credentialName: {{ .Values.istio.gateway.credentialName }}
        {{- if .Values.istio.gateway.caCertificates }}
        caCertificates: {{ .Values.istio.gateway.caCertificates }}
        {{- end }}
        {{- end }}
    {{- end }}
    {{- end }}
{{- end }}
{{- end -}}