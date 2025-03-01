{{- define "common.persistentvolumeclaim.tpl" -}}
{{- if .Values.persistence.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.persistence.name | default (include "common.fullname" .) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.persistence.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.persistence.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.persistence.storageClassName }}
  storageClassName: {{ .Values.persistence.storageClassName }}
  {{- end }}
  {{- if .Values.persistence.volumeName }}
  volumeName: {{ .Values.persistence.volumeName }}
  {{- else if and .Values.persistence.persistentVolume.create .Values.persistence.persistentVolume.name }}
  volumeName: {{ .Values.persistence.persistentVolume.name }}
  {{- else if .Values.persistence.persistentVolume.create }}
  volumeName: {{ printf "%s-pv" (include "common.fullname" .) }}
  {{- end }}
  accessModes:
    {{- range .Values.persistence.accessModes }}
    - {{ . }}
    {{- end }}
  resources:
    requests:
      storage: {{ .Values.persistence.size | default "10Gi" }}
  {{- if eq .Values.persistence.volumeMode "Filesystem" }}
  volumeMode: Filesystem
  {{- else if eq .Values.persistence.volumeMode "Block" }}
  volumeMode: Block
  {{- end }}
  {{- if .Values.persistence.selector }}
  selector:
    {{- toYaml .Values.persistence.selector | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}