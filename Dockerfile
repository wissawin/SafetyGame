FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 8080
RUN sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/conf.d/default.conf && \
    sed -i '/location \/ {/a \        add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0" always;\n        add_header Pragma "no-cache" always;\n        add_header Expires "0" always;' /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
