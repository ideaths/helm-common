# templates/common/pdb.tpl
{{- if .Values.pdb.create }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "yourchart.fullname" . }}-pdb
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  minAvailable: {{ .Values.pdb.minAvailable }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "yourchart.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
