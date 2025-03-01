{{- define "common.istio.peerAuthentication.tpl" -}}
{{- if .Values.istio.peerAuthentication.enabled }}
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: {{ include "common.fullname" . }}-peerauth
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  mtls:
    mode: {{ .Values.istio.peerAuthentication.mtls.mode }}
{{- end }}
{{- end -}}
