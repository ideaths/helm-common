{{- define "common.deployment.tpl" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "common.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      {{- if .Values.serviceAccount.create }}
      serviceAccountName: {{ include "common.serviceAccountName" . }}
      {{- else if .Values.serviceAccount.name }}
      serviceAccountName: {{ .Values.serviceAccount.name }}
      {{- end }}
      
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
              name: http
          {{- if .Values.env.enabled }}
          env:
            {{- toYaml .Values.env | nindent 12 }}
          {{- end }}
          {{- if and .Values.livenessProbe.enabled .Values.livenessProbe.httpGet }}
          livenessProbe:
            httpGet:
              path: {{ .Values.livenessProbe.httpGet.path }}
              port: {{ .Values.livenessProbe.httpGet.port }}
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
            successThreshold: {{ .Values.livenessProbe.successThreshold }}
            timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
          {{- end }}
          {{- if and .Values.readinessProbe.enabled .Values.readinessProbe.httpGet }}
          readinessProbe:
            httpGet:
              path: {{ .Values.readinessProbe.httpGet.path }}
              port: {{ .Values.readinessProbe.httpGet.port }}
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
            successThreshold: {{ .Values.readinessProbe.successThreshold }}
            timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
          {{- end }}
          {{- if .Values.resources.enabled }}
          resources:
            limits:
              cpu: "{{ .Values.resources.limits.cpu }}"
              memory: "{{ .Values.resources.limits.memory }}"
            requests:
              cpu: "{{ .Values.resources.requests.cpu }}"
              memory: "{{ .Values.resources.requests.memory }}"
          {{- end }}
          {{- with .Values.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if .Values.volumeMounts.create }}
          volumeMounts:
            {{- range .Values.volumeMounts.mountPoint }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              {{- if .readOnly }}
              readOnly: true
              {{- end }}
              {{- if .subPath }}
              subPath: {{ .subPath }}
              {{- end }}
            {{- end }}
          {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      {{- with .Values.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      {{- if .Values.volumes.create }}
      volumes:
        {{- range .Values.volumes.mount }}
        - name: {{ .name }}
          {{- if .emptyDir }}
          emptyDir: {}
          {{- end }}
          {{- if .configMap }}
          configMap:
            name: {{ .configMap.name }}
            defaultMode: {{ .configMap.defaultMode }}
            optional: {{ .configMap.optional }}
            {{- if .configMap.items }}
            items:
              {{- range .configMap.items }}
              - key: {{ .key }}
                path: {{ .path }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
{{- end -}}
