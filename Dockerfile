# Dockerfile - Runtime only (JDK 21, não-root)

# Imagem oficial e otimizada
FROM openjdk:21-jdk-slim

# Define o profile de produção (não usa application-dev.properties)
ENV SPRING_PROFILES_ACTIVE=production

WORKDIR /app

# Cria grupo e usuário sem privilégios (não-root)
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copia APENAS o JAR gerado pelo Gradle no CI
# O pipeline garante que build/libs/ já existe antes do docker build
COPY build/libs/*.jar /app/app.jar

# Ajusta permissões para o usuário não-root
RUN chown -R appuser:appgroup /app

# Troca para o usuário sem privilégios
USER appuser

# Expõe a porta usada pela aplicação (configurada em application.properties)
EXPOSE 8081

# Executa a aplicação em primeiro plano (correto para Docker)
ENTRYPOINT ["java", "-jar", "/app/app.jar"]