{{- define "common.ingress.tpl" -}}
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.defaultBackend }}
  defaultBackend:
    {{- if .Values.ingress.defaultBackend.service }}
    service:
      name: {{ .Values.ingress.defaultBackend.service.name | default (include "common.fullname" .) }}
      port:
        number: {{ .Values.ingress.defaultBackend.service.port | default .Values.service.port }}
    {{- end }}
    {{- if .Values.ingress.defaultBackend.resource }}
    resource:
      apiGroup: {{ .Values.ingress.defaultBackend.resource.apiGroup }}
      kind: {{ .Values.ingress.defaultBackend.resource.kind }}
      name: {{ .Values.ingress.defaultBackend.resource.name }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- if .paths }}
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                name: {{ .serviceName | default (include "common.fullname" $) }}
                port:
                  {{- if .servicePort }}
                  number: {{ .servicePort }}
                  {{- else }}
                  number: {{ $.Values.service.port }}
                  {{- end }}
          {{- end }}
          {{- else }}
          - path: {{ .path | default "/" }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                name: {{ include "common.fullname" $ }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}