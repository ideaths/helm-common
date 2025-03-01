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
      # ServiceAccount Configuration
      {{- if .Values.serviceAccount.create }}
      serviceAccountName: {{ include "common.serviceAccountName" . }}
      {{- else if .Values.serviceAccount.name }}
      serviceAccountName: {{ .Values.serviceAccount.name }}
      {{- end }}
      
      # Image Pull Secrets
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      # Main Container
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
              name: http
          
          # Environment Variables
          {{- if .Values.env.enabled }}
          env:
            {{- toYaml .Values.env | nindent 12 }}
          {{- end }}
          
          # Liveness Probe
          {{- if .Values.livenessProbe.enabled }}
          livenessProbe:
            {{- if .Values.livenessProbe.httpGet }}
            httpGet:
              path: {{ .Values.livenessProbe.httpGet.path }}
              port: {{ .Values.livenessProbe.httpGet.port }}
              {{- with .Values.livenessProbe.httpGet.httpHeaders }}
              httpHeaders:
                {{- toYaml . | nindent 16 }}
              {{- end }}
            {{- else if .Values.livenessProbe.tcpSocket }}
            tcpSocket:
              port: {{ .Values.livenessProbe.tcpSocket.port }}
            {{- else if .Values.livenessProbe.exec }}
            exec:
              command:
                {{- toYaml .Values.livenessProbe.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds | default 30 }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds | default 10 }}
            timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds | default 5 }}
            successThreshold: {{ .Values.livenessProbe.successThreshold | default 1 }}
            failureThreshold: {{ .Values.livenessProbe.failureThreshold | default 3 }}
          {{- end }}
          
          # Readiness Probe
          {{- if .Values.readinessProbe.enabled }}
          readinessProbe:
            {{- if .Values.readinessProbe.httpGet }}
            httpGet:
              path: {{ .Values.readinessProbe.httpGet.path }}
              port: {{ .Values.readinessProbe.httpGet.port }}
              {{- with .Values.readinessProbe.httpGet.httpHeaders }}
              httpHeaders:
                {{- toYaml . | nindent 16 }}
              {{- end }}
            {{- else if .Values.readinessProbe.tcpSocket }}
            tcpSocket:
              port: {{ .Values.readinessProbe.tcpSocket.port }}
            {{- else if .Values.readinessProbe.exec }}
            exec:
              command:
                {{- toYaml .Values.readinessProbe.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds | default 30 }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds | default 10 }}
            timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds | default 5 }}
            successThreshold: {{ .Values.readinessProbe.successThreshold | default 1 }}
            failureThreshold: {{ .Values.readinessProbe.failureThreshold | default 3 }}
          {{- end }}
          
          # Startup Probe
          {{- if and .Values.startupProbe .Values.startupProbe.enabled }}
          startupProbe:
            {{- if .Values.startupProbe.httpGet }}
            httpGet:
              path: {{ .Values.startupProbe.httpGet.path }}
              port: {{ .Values.startupProbe.httpGet.port }}
            {{- else if .Values.startupProbe.tcpSocket }}
            tcpSocket:
              port: {{ .Values.startupProbe.tcpSocket.port }}
            {{- else if .Values.startupProbe.exec }}
            exec:
              command:
                {{- toYaml .Values.startupProbe.exec.command | nindent 16 }}
            {{- end }}
            initialDelaySeconds: {{ .Values.startupProbe.initialDelaySeconds | default 30 }}
            periodSeconds: {{ .Values.startupProbe.periodSeconds | default 10 }}
            timeoutSeconds: {{ .Values.startupProbe.timeoutSeconds | default 5 }}
            successThreshold: {{ .Values.startupProbe.successThreshold | default 1 }}
            failureThreshold: {{ .Values.startupProbe.failureThreshold | default 3 }}
          {{- end }}
          
          # Resources
          {{- if .Values.resources.enabled }}
          resources:
            {{- if .Values.resources.limits }}
            limits:
              {{- if .Values.resources.limits.cpu }}
              cpu: "{{ .Values.resources.limits.cpu }}"
              {{- end }}
              {{- if .Values.resources.limits.memory }}
              memory: "{{ .Values.resources.limits.memory }}"
              {{- end }}
            {{- end }}
            {{- if .Values.resources.requests }}
            requests:
              {{- if .Values.resources.requests.cpu }}
              cpu: "{{ .Values.resources.requests.cpu }}"
              {{- end }}
              {{- if .Values.resources.requests.memory }}
              memory: "{{ .Values.resources.requests.memory }}"
              {{- end }}
            {{- end }}
          {{- end }}
          
          # Security Context
          {{- with .Values.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          
          # Volume Mounts
          {{- if or .Values.volumeMounts.create (and .Values.persistence .Values.persistence.enabled) }}
          volumeMounts:
            {{- if .Values.volumeMounts.create }}
            {{- range .Values.volumeMounts.mountPoint }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              {{- if .readOnly }}
              readOnly: {{ .readOnly }}
              {{- end }}
              {{- if .subPath }}
              subPath: {{ .subPath }}
              {{- end }}
              {{- if .mountPropagation }}
              mountPropagation: {{ .mountPropagation }}
              {{- end }}
            {{- end }}
            {{- end }}
            {{- if and .Values.persistence .Values.persistence.enabled }}
            - name: persistent-storage
              mountPath: {{ .Values.persistence.mountPath }}
              {{- if .Values.persistence.subPath }}
              subPath: {{ .Values.persistence.subPath }}
              {{- end }}
            {{- end }}
          {{- end }}
          
      # Node Selector
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      # Tolerations
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      # Affinity
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      # Pod Security Context
      {{- with .Values.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      # Volumes
      {{- if or .Values.volumes.create (and .Values.persistence .Values.persistence.enabled) }}
      volumes:
        {{- if .Values.volumes.create }}
        {{- range .Values.volumes.mount }}
        - name: {{ .name }}
          {{- if .emptyDir }}
          emptyDir: 
            {{- if .emptyDir.sizeLimit }}
            sizeLimit: {{ .emptyDir.sizeLimit }}
            {{- else }}
            {}
            {{- end }}
          {{- end }}
          
          {{- if .configMap }}
          configMap:
            name: {{ .configMap.name }}
            {{- if .configMap.defaultMode }}
            defaultMode: {{ .configMap.defaultMode }}
            {{- end }}
            {{- if hasKey .configMap "optional" }}
            optional: {{ .configMap.optional }}
            {{- end }}
            {{- if .configMap.items }}
            items:
              {{- range .configMap.items }}
              - key: {{ .key }}
                path: {{ .path }}
              {{- end }}
            {{- end }}
          {{- end }}
          
          {{- if .secret }}
          secret:
            secretName: {{ .secret.secretName }}
            {{- if .secret.defaultMode }}
            defaultMode: {{ .secret.defaultMode }}
            {{- end }}
            {{- if hasKey .secret "optional" }}
            optional: {{ .secret.optional }}
            {{- end }}
            {{- if .secret.items }}
            items:
              {{- range .secret.items }}
              - key: {{ .key }}
                path: {{ .path }}
              {{- end }}
            {{- end }}
          {{- end }}
          
          {{- if .hostPath }}
          hostPath:
            path: {{ .hostPath.path }}
            {{- if .hostPath.type }}
            type: {{ .hostPath.type }}
            {{- end }}
          {{- end }}
          
          {{- if .persistentVolumeClaim }}
          persistentVolumeClaim:
            claimName: {{ .persistentVolumeClaim.claimName }}
          {{- end }}
          
          {{- if .projected }}
          projected:
            {{- toYaml .projected | nindent 12 }}
          {{- end }}
        {{- end }}
        {{- end }}
        
        {{- if and .Values.persistence .Values.persistence.enabled }}
        - name: persistent-storage
          persistentVolumeClaim:
            claimName: {{ .Values.persistence.existingClaim | default (include "common.fullname" .) }}
        {{- end }}
      {{- end }}
{{- end -}}