# =====================================================================
# Dockerfile untuk deploy ke Render (atau hosting lain yang mendukung Docker)
# Isinya: Tomcat 10.1 + Java 21, driver MySQL, lalu folder web/ disalin
# sebagai aplikasi ROOT sehingga website bisa dibuka di alamat utama "/".
# =====================================================================
FROM tomcat:10.1-jdk21

# Zona waktu Indonesia (WIB)
ENV TZ=Asia/Jakarta

# Hapus aplikasi bawaan Tomcat (kalau ada)
RUN rm -rf /usr/local/tomcat/webapps/*

# Driver JDBC MySQL (dipakai untuk konek ke database MySQL / TiDB)
ADD https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar /usr/local/tomcat/lib/
RUN chmod 644 /usr/local/tomcat/lib/mysql-connector-j-8.4.0.jar

# Salin semua file website
COPY web/ /usr/local/tomcat/webapps/ROOT/

EXPOSE 8080
CMD ["catalina.sh", "run"]
