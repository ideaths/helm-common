# templates/istio/destinationRule.tpl
{{- if .Values.istio.destinationRule.enabled }}
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: {{ include "yourchart.fullname" . }}-destinationrule
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  host: {{ include "yourchart.fullname" . }}
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    connectionPool:
      tcp:
        maxConnections: {{ .Values.istio.destinationRule.trafficPolicy.connectionPool.tcp.maxConnections }}
      http:
        http1MaxPendingRequests: {{ .Values.istio.destinationRule.trafficPolicy.connectionPool.http.http1MaxPendingRequests }}
        http2MaxRequests: {{ .Values.istio.destinationRule.trafficPolicy.connectionPool.http.http2MaxRequests }}
    outlierDetection:
      consecutive5xxErrors: {{ .Values.istio.destinationRule.trafficPolicy.outlierDetection.consecutive5xxErrors }}
      interval: {{ .Values.istio.destinationRule.trafficPolicy.outlierDetection.interval }}
      baseEjectionTime: {{ .Values.istio.destinationRule.trafficPolicy.outlierDetection.baseEjectionTime }}
      maxEjectionPercent: {{ .Values.istio.destinationRule.trafficPolicy.outlierDetection.maxEjectionPercent }}
{{- end }}
