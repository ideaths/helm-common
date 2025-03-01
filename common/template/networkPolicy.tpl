{{- define "common.networkPolicy.tpl" -}}
{{- if .Values.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ .Values.networkPolicy.name | default (printf "%s-networkpolicy" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.networkPolicy.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  podSelector:
    {{- if .Values.networkPolicy.podSelector }}
    matchLabels:
      {{- toYaml .Values.networkPolicy.podSelector | nindent 6 }}
    {{- else }}
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
    {{- end }}
  policyTypes:
    {{- if .Values.networkPolicy.ingress }}
    - Ingress
    {{- end }}
    {{- if .Values.networkPolicy.egress }}
    - Egress
    {{- end }}
  
  {{- if .Values.networkPolicy.ingress }}
  ingress:
    {{- if .Values.networkPolicy.ingress.from }}
    {{- range .Values.networkPolicy.ingress.from }}
    - from:
      {{- if .podSelector }}
      - podSelector:
          matchLabels:
            {{- toYaml .podSelector | nindent 14 }}
      {{- end }}
      {{- if .namespaceSelector }}
      - namespaceSelector:
          matchLabels:
            {{- toYaml .namespaceSelector | nindent 14 }}
      {{- end }}
      {{- if .ipBlock }}
      - ipBlock:
          {{- toYaml .ipBlock | nindent 12 }}
      {{- end }}
      {{- if .ports }}
      ports:
        {{- range .ports }}
        - protocol: {{ .protocol | default "TCP" }}
          port: {{ .port }}
        {{- end }}
      {{- else if $.Values.service.port }}
      ports:
        - protocol: TCP
          port: {{ $.Values.service.port }}
      {{- end }}
    {{- end }}
    {{- else }}
    # If no from selectors are specified, default to allowing all
    - {}
    {{- end }}
  {{- end }}
  
  {{- if .Values.networkPolicy.egress }}
  egress:
    {{- if .Values.networkPolicy.egress.to }}
    {{- range .Values.networkPolicy.egress.to }}
    - to:
      {{- if .podSelector }}
      - podSelector:
          matchLabels:
            {{- toYaml .podSelector | nindent 14 }}
      {{- end }}
      {{- if .namespaceSelector }}
      - namespaceSelector:
          matchLabels:
            {{- toYaml .namespaceSelector | nindent 14 }}
      {{- end }}
      {{- if .ipBlock }}
      - ipBlock:
          {{- toYaml .ipBlock | nindent 12 }}
      {{- end }}
      {{- if .ports }}
      ports:
        {{- range .ports }}
        - protocol: {{ .protocol | default "TCP" }}
          port: {{ .port }}
        {{- end }}
      {{- else if $.Values.service.port }}
      ports:
        - protocol: TCP
          port: {{ $.Values.service.port }}
      {{- end }}
    {{- end }}
    {{- else }}
    # If no to selectors are specified, default to allowing all
    - {}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}