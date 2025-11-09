# Dockerfile - Runtime only (JDK 21, não-root) - V2 (eclipse-temurin)

# Imagem oficial e otimizada (eclipse-temurin com JRE/Alpine)
FROM eclipse-temurin:21-jre-alpine

# Define o profile de produção
ENV SPRING_PROFILES_ACTIVE=production

# Define diretório de trabalho
WORKDIR /app

# Cria grupo e usuário não-root (versão Alpine Linux)
RUN addgroup -S appgroup && adduser -S -G appgroup appuser

# Copia APENAS o JAR gerado pelo Gradle
# (Isto vai funcionar porque o seu '.\gradlew clean bootJar' já ocorreu com sucesso)
COPY build/libs/*.jar /app/app.jar

# Define permissões para o usuário não-root
RUN chown -R appuser:appgroup /app

# Troca para o usuário sem privilégios
USER appuser

# Expõe a porta usada pela aplicação
EXPOSE 8081

# Executa a aplicação em primeiro plano
ENTRYPOINT ["java", "-jar", "/app/app.jar"]









