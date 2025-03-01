{{- define "common.persistentvolume.tpl" -}}
{{- if .Values.persistence.persistentVolume.create }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ .Values.persistence.persistentVolume.name | default (printf "%s-pv" (include "common.fullname" .)) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    type: local
    {{- with .Values.persistence.persistentVolume.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.persistence.persistentVolume.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  storageClassName: {{ .Values.persistence.persistentVolume.storageClassName | default "standard" }}
  capacity:
    storage: {{ .Values.persistence.size | default "10Gi" }}
  accessModes:
    {{- range .Values.persistence.accessModes }}
    - {{ . }}
    {{- end }}
  {{- if eq .Values.persistence.persistentVolume.volumeMode "Filesystem" }}
  volumeMode: Filesystem
  {{- else if eq .Values.persistence.persistentVolume.volumeMode "Block" }}
  volumeMode: Block
  {{- end }}
  persistentVolumeReclaimPolicy: {{ .Values.persistence.persistentVolume.reclaimPolicy | default "Retain" }}
  {{- if .Values.persistence.persistentVolume.hostPath }}
  hostPath:
    path: {{ .Values.persistence.persistentVolume.hostPath.path }}
    {{- if .Values.persistence.persistentVolume.hostPath.type }}
    type: {{ .Values.persistence.persistentVolume.hostPath.type }}
    {{- end }}
  {{- else if .Values.persistence.persistentVolume.nfs }}
  nfs:
    server: {{ .Values.persistence.persistentVolume.nfs.server }}
    path: {{ .Values.persistence.persistentVolume.nfs.path }}
  {{- else if .Values.persistence.persistentVolume.csi }}
  csi:
    driver: {{ .Values.persistence.persistentVolume.csi.driver }}
    volumeHandle: {{ .Values.persistence.persistentVolume.csi.volumeHandle }}
    {{- if .Values.persistence.persistentVolume.csi.fsType }}
    fsType: {{ .Values.persistence.persistentVolume.csi.fsType }}
    {{- end }}
    {{- with .Values.persistence.persistentVolume.csi.volumeAttributes }}
    volumeAttributes:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- else if .Values.persistence.persistentVolume.local }}
  local:
    path: {{ .Values.persistence.persistentVolume.local.path }}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: {{ .Values.persistence.persistentVolume.local.nodeAffinityKey | default "kubernetes.io/hostname" }}
          operator: In
          values:
          - {{ .Values.persistence.persistentVolume.local.nodeAffinityValue }}
  {{- end }}
{{- end }}
{{- end -}}