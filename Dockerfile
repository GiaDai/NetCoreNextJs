#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 8088

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["web.csproj", "."]
RUN dotnet restore "./web.csproj"
COPY . .
WORKDIR "/src/."
RUN mkdir -p /src/client-app/.next
RUN dotnet build "web.csproj" -c Release -o /app/build

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install -y nodejs

FROM build AS publish
RUN dotnet publish "web.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "web.dll"]