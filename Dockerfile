FROM mcr.microsoft.com/dotnet/aspnet:5.0-focal AS base
WORKDIR /app
EXPOSE 80

ENV ASPNETCORE_URLS=http://+:80

FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
WORKDIR /src
COPY ["aksOnBicep.csproj", "./"]
RUN dotnet restore "aksOnBicep.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "aksOnBicep.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "aksOnBicep.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "aksOnBicep.dll"]
