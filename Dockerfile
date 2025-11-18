# ====================================================================
# STAGE 1: BASE (RUNTIME)
# Usa la imagen de ASP.NET Runtime 9.0 para ejecutar la app
# ====================================================================
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 10000
# El entorno de producción es ideal para un despliegue
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:10000

# ====================================================================
# STAGE 2: BUILD
# Usa la imagen de .NET SDK 9.0 para compilar la app
# ====================================================================
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
# Copia solo el archivo del proyecto para restaurar dependencias primero
COPY ["semana13OscarMamaniAyala.csproj", "."]

# Restaura las dependencias (NuGet packages)
RUN dotnet restore "semana13OscarMamaniAyala.csproj"

# Copia el resto del código fuente
COPY . .

# Compila la aplicación en modo Release
RUN dotnet build "semana13OscarMamaniAyala.csproj" -c Release -o /app/build

# ====================================================================
# STAGE 3: PUBLISH
# Publica la aplicación final
# ====================================================================
FROM build AS publish
# Publica la aplicación. UseAppHost=false evita crear un ejecutable nativo innecesario
RUN dotnet publish "semana13OscarMamaniAyala.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ====================================================================
# STAGE 4: FINAL (CREACIÓN DE LA IMAGEN LIGERA)
# Copia los archivos publicados al Runtime Base
# ====================================================================
FROM base AS final
WORKDIR /app
# Copia solo los archivos listos para ejecutar
COPY --from=publish /app/publish .
# Define el punto de entrada para ejecutar la DLL de tu proyecto
ENTRYPOINT ["dotnet", "semana13OscarMamaniAyala.dll"]