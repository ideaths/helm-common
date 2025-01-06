apiVersion: v1
kind: Service
metadata:
  name: {{ include "yourchart.fullname" . }}
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: {{ include "yourchart.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
