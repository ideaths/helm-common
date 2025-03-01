{{- define "common.istio.virtualService.tpl" -}}
{{- if .Values.istio.virtualService.enabled }}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: {{ include "common.fullname" . }}-virtualservice
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  hosts:
    - "{{ .Values.istio.virtualService.host }}"
  gateways:
    - {{ include "common.fullname" . }}-gateway
  http:
    - match:
        - uri:
            prefix: "/"
      route:
        - destination:
            host: {{ include "common.fullname" . }}
            port:
              number: {{ .Values.service.port }}
{{- end }}
{{- end -}}
