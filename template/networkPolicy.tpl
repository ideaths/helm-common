{{- define "common.networkPolicy.tpl" -}}
{{- if .Values.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "common.fullname" . }}-networkpolicy
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    {{- range .Values.networkPolicy.ingress.from }}
    - from:
        - podSelector:
            matchLabels:
              {{- toYaml .podSelector | nindent 16 }}
      ports:
        - protocol: TCP
          port: {{ $.Values.service.port }}
    {{- end }}
  egress:
    {{- range .Values.networkPolicy.egress.to }}
    - to:
        - podSelector:
            matchLabels:
              {{- toYaml .podSelector | nindent 16 }}
      ports:
        - protocol: TCP
          port: {{ $.Values.service.port }}
    {{- end }}
{{- end }}
{{- end -}}
