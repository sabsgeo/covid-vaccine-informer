FROM ubuntu:20.04
ARG SENDER_EMAIL
RUN : "${SENDER_EMAIL:? SENDER_EMAIL Cannot be empty}"

ARG SENDER_EMAIL_PASSWORD
RUN : "${SENDER_EMAIL_PASSWORD:? SENDER_EMAIL_PASSWORD Cannot be empty}"
    
RUN apt-get update -y && \
    apt-get install jq curl ssmtp -y

RUN echo "root=$SENDER_EMAIL" > /etc/ssmtp/ssmtp.conf
RUN echo "mailhub=smtp.gmail.com:465" >> /etc/ssmtp/ssmtp.conf
RUN echo "rewriteDomain=gmail.com" >> /etc/ssmtp/ssmtp.conf
RUN echo "AuthUser=$SENDER_EMAIL" >> /etc/ssmtp/ssmtp.conf
RUN echo "AuthPass=$SENDER_EMAIL_PASSWORD" >> /etc/ssmtp/ssmtp.conf
RUN echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
RUN echo "UseTLS=YES" >> /etc/ssmtp/ssmtp.conf

ENV SENDER_EMAIL $SENDER_EMAIL 

COPY covid-vaccine.sh /covid-vaccine.sh
RUN chmod +x /covid-vaccine.sh

RUN cat /etc/ssmtp/ssmtp.conf

ENTRYPOINT ["/bin/bash", "-c" , "/covid-vaccine.sh"]
