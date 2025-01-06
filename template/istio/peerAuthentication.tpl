# templates/istio/peerAuthentication.tpl
{{- if .Values.istio.peerAuthentication.enabled }}
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: {{ include "yourchart.fullname" . }}-peerauth
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "yourchart.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  mtls:
    mode: {{ .Values.istio.peerAuthentication.mtls.mode }}
{{- end }}
