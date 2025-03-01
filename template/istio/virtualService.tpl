{{- define "common.istio.virtualService.tpl" -}}
{{- if .Values.istio.virtualService.enabled }}
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: {{ .Values.istio.virtualService.name | default (printf "%s-virtualservice" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.istio.virtualService.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  hosts:
    {{- if .Values.istio.virtualService.hosts }}
    {{- toYaml .Values.istio.virtualService.hosts | nindent 4 }}
    {{- else }}
    - {{ .Values.istio.virtualService.host | default "*" }}
    {{- end }}
  {{- if .Values.istio.virtualService.exportTo }}
  exportTo:
    - {{ .Values.istio.virtualService.exportTo }}
  {{- end }}
  gateways:
    {{- if .Values.istio.virtualService.gateways }}
    {{- toYaml .Values.istio.virtualService.gateways | nindent 4 }}
    {{- else }}
    - {{ .Values.istio.virtualService.gateway | default (printf "%s-gateway" (include "common.fullname" .)) }}
    {{- end }}
  {{- if .Values.istio.virtualService.http }}
  http:
    {{- toYaml .Values.istio.virtualService.http | nindent 4 }}
  {{- else }}
  http:
    - match:
        {{- if .Values.istio.virtualService.match }}
        {{- toYaml .Values.istio.virtualService.match | nindent 8 }}
        {{- else }}
        - uri:
            prefix: {{ .Values.istio.virtualService.prefix | default "/" }}
        {{- end }}
      {{- if .Values.istio.virtualService.rewrite }}
      rewrite:
        {{- toYaml .Values.istio.virtualService.rewrite | nindent 8 }}
      {{- end }}
      {{- if .Values.istio.virtualService.timeout }}
      timeout: {{ .Values.istio.virtualService.timeout }}
      {{- end }}
      {{- if .Values.istio.virtualService.retries }}
      retries:
        {{- toYaml .Values.istio.virtualService.retries | nindent 8 }}
      {{- end }}
      {{- if .Values.istio.virtualService.fault }}
      fault:
        {{- toYaml .Values.istio.virtualService.fault | nindent 8 }}
      {{- end }}
      {{- if .Values.istio.virtualService.mirror }}
      mirror:
        {{- toYaml .Values.istio.virtualService.mirror | nindent 8 }}
      {{- end }}
      {{- if .Values.istio.virtualService.corsPolicy }}
      corsPolicy:
        {{- toYaml .Values.istio.virtualService.corsPolicy | nindent 8 }}
      {{- end }}
      {{- if .Values.istio.virtualService.headers }}
      headers:
        {{- toYaml .Values.istio.virtualService.headers | nindent 8 }}
      {{- end }}
      route:
        {{- if .Values.istio.virtualService.route }}
        {{- toYaml .Values.istio.virtualService.route | nindent 8 }}
        {{- else }}
        - destination:
            host: {{ .Values.istio.virtualService.destination.host | default (include "common.fullname" .) }}
            {{- if .Values.istio.virtualService.destination.subset }}
            subset: {{ .Values.istio.virtualService.destination.subset }}
            {{- end }}
            port:
              number: {{ .Values.istio.virtualService.destination.port | default .Values.service.port }}
          {{- if .Values.istio.virtualService.destination.weight }}
          weight: {{ .Values.istio.virtualService.destination.weight }}
          {{- end }}
        {{- end }}
  {{- end }}
  
  {{- if .Values.istio.virtualService.tcp }}
  tcp:
    {{- toYaml .Values.istio.virtualService.tcp | nindent 4 }}
  {{- end }}
  
  {{- if .Values.istio.virtualService.tls }}
  tls:
    {{- toYaml .Values.istio.virtualService.tls | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}