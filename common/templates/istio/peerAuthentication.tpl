{{- define "common.istio.peerAuthentication.tpl" -}}
{{- if .Values.istio.peerAuthentication.enabled }}
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: {{ .Values.istio.peerAuthentication.name | default (printf "%s-peerauth" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.istio.peerAuthentication.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.istio.peerAuthentication.selector }}
  selector:
    matchLabels:
      {{- toYaml .Values.istio.peerAuthentication.selector | nindent 6 }}
  {{- else }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  {{- end }}
  {{- if .Values.istio.peerAuthentication.mtls }}
  mtls:
    {{- if kindIs "string" .Values.istio.peerAuthentication.mtls }}
    mode: {{ .Values.istio.peerAuthentication.mtls }}
    {{- else if kindIs "map" .Values.istio.peerAuthentication.mtls }}
    mode: {{ .Values.istio.peerAuthentication.mtls.mode }}
    {{- end }}
  {{- end }}
  {{- if .Values.istio.peerAuthentication.portLevelMtls }}
  portLevelMtls:
    {{- toYaml .Values.istio.peerAuthentication.portLevelMtls | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}