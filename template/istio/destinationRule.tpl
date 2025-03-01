{{- define "common.istio.destinationRule.tpl" -}}
{{- if .Values.istio.destinationRule.enabled }}
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: {{ .Values.istio.destinationRule.name | default (printf "%s-destinationrule" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.istio.destinationRule.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  host: {{ .Values.istio.destinationRule.host | default (include "common.fullname" .) }}
  {{- if .Values.istio.destinationRule.exportTo }}
  exportTo:
    - {{ .Values.istio.destinationRule.exportTo }}
  {{- end }}
  {{- if .Values.istio.destinationRule.subsets }}
  subsets:
    {{- toYaml .Values.istio.destinationRule.subsets | nindent 4 }}
  {{- end }}
  {{- if .Values.istio.destinationRule.trafficPolicy }}
  trafficPolicy:
    {{- if kindIs "string" .Values.istio.destinationRule.trafficPolicy }}
    {{- toYaml (fromYaml .Values.istio.destinationRule.trafficPolicy) | nindent 4 }}
    {{- else }}
    {{- if .Values.istio.destinationRule.trafficPolicy.loadBalancer }}
    loadBalancer:
      {{- toYaml .Values.istio.destinationRule.trafficPolicy.loadBalancer | nindent 6 }}
    {{- else }}
    loadBalancer:
      simple: {{ .Values.istio.destinationRule.trafficPolicy.loadBalancerType | default "ROUND_ROBIN" }}
    {{- end }}
    
    {{- if .Values.istio.destinationRule.trafficPolicy.connectionPool }}
    connectionPool:
      {{- if .Values.istio.destinationRule.trafficPolicy.connectionPool.tcp }}
      tcp:
        {{- toYaml .Values.istio.destinationRule.trafficPolicy.connectionPool.tcp | nindent 8 }}
      {{- end }}
      {{- if .Values.istio.destinationRule.trafficPolicy.connectionPool.http }}
      http:
        {{- toYaml .Values.istio.destinationRule.trafficPolicy.connectionPool.http | nindent 8 }}
      {{- end }}
    {{- end }}
    
    {{- if .Values.istio.destinationRule.trafficPolicy.outlierDetection }}
    outlierDetection:
      {{- toYaml .Values.istio.destinationRule.trafficPolicy.outlierDetection | nindent 6 }}
    {{- end }}
    
    {{- if .Values.istio.destinationRule.trafficPolicy.tls }}
    tls:
      {{- toYaml .Values.istio.destinationRule.trafficPolicy.tls | nindent 6 }}
    {{- end }}
    
    {{- if .Values.istio.destinationRule.trafficPolicy.portLevelSettings }}
    portLevelSettings:
      {{- toYaml .Values.istio.destinationRule.trafficPolicy.portLevelSettings | nindent 6 }}
    {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}