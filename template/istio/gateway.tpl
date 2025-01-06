# templates/istio/gateway.tpl
{{- if .Values.istio.gateway.enabled }}
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: {{ include "yourchart.fullname" . }}-gateway
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  selector:
    istio: {{ .Values.istio.gateway.selector }}
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "{{ .Values.istio.gateway.host }}"
    - port:
        number: 443
        name: https
        protocol: HTTPS
      hosts:
        - "{{ .Values.istio.gateway.host }}"
      tls:
        mode: SIMPLE
        credentialName: {{ .Values.istio.gateway.credentialName }}
{{- end }}
