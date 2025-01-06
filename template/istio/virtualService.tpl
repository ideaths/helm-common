# templates/istio/virtualService.tpl
{{- if .Values.istio.virtualService.enabled }}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: {{ include "yourchart.fullname" . }}-virtualservice
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  hosts:
    - "{{ .Values.istio.virtualService.host }}"
  gateways:
    - {{ include "yourchart.fullname" . }}-gateway
  http:
    - match:
        - uri:
            prefix: "/"
      route:
        - destination:
            host: {{ include "yourchart.fullname" . }}
            port:
              number: {{ .Values.service.port }}
{{- end }}
