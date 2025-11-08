# Dockerfile - Runtime only (JDK 21, não-root) - V2 (eclipse-temurin)

# Requisito A: Imagem oficial e otimizada (eclipse-temurin com JRE/Alpine)
FROM eclipse-temurin:21-jre-alpine

# Requisito E: Define o profile de produção
ENV SPRING_PROFILES_ACTIVE=production

WORKDIR /app

# Requisito C: Cria grupo e usuário não-root (versão Alpine Linux)
RUN addgroup -S appgroup && adduser -S -G appgroup appuser

# Copia APENAS o JAR gerado pelo Gradle
# (Isto vai funcionar porque o seu '.\gradlew clean bootJar' já correu com sucesso)
COPY build/libs*.jar /app/app.jar

# Requisito C: Define permissões para o usuário não-root
RUN chown -R appuser:appgroup /app

# Requisito C: Troca para o usuário sem privilégios
USER appuser

# Requisito D: Expõe a porta usada pela aplicação
EXPOSE 8081

# Requisito B: Executa a aplicação em primeiro plano
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
