# templates/common/networkPolicy.tpl
{{- if .Values.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "yourchart.fullname" . }}-networkpolicy
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: {{ include "yourchart.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
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
