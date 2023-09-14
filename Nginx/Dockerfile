FROM ubuntu
RUN apt update && apt install nginx -y
RUN rm -rf /var/www/html/*
RUN echo "this is a webserver" > /var/www/html/index.html
EXPOSE 80

CMD ["nginx","-g","daemon off;"]
