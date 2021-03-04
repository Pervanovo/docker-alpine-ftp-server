FROM alpine:3.13
RUN apk --no-cache add vsftpd

ENV VSFTP_CONF=/etc/vsftpd/vsftpd.conf

COPY start_vsftpd.sh /bin/start_vsftpd.sh
COPY vsftpd.conf $VSFTP_CONF

EXPOSE 21 21000-21010
VOLUME /ftp/ftp

ENTRYPOINT ["/bin/start_vsftpd.sh"]

