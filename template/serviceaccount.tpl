# templates/common/serviceaccount.tpl
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "yourchart.fullname" . }}
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
  annotations:
    {{- toYaml .Values.serviceAccount.annotations | nindent 4 }}
{{- else if .Values.serviceAccount.name }}
# Sử dụng ServiceAccount đã tồn tại
# Không tạo mới, chỉ sử dụng tên được cung cấp
# Đảm bảo rằng tên ServiceAccount đã tồn tại trong cluster
{{- end }}
