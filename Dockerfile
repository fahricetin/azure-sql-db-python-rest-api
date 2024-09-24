# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies (including ODBC)
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    odbcinst \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y telnet curl iputils-ping

# If you're connecting to SQL Server, install the Microsoft ODBC driver
# Uncomment the following lines if needed
RUN apt-get update && apt-get install -y \
    curl \
    apt-transport-https \
    gnupg2 \
    unixodbc \
    unixodbc-dev \
    odbcinst \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && apt-get clean -y
    

# Copy the requirements.txt file first for caching
COPY requirements.txt .

# Install the required Python packages
RUN pip install --no-cache-dir -r requirements.txt


# Copy the current directory contents into the container
COPY . .


# Set environment variables
ENV FLASK_ENV=development
ENV SQLAZURECONNSTR_WWIF="={ODBC Driver 17 for SQL Server};SERVER=193.168.65.3,1433;DATABASE=WideWorldImporters-Full;UID=PythonWebApp;PWD=a987REALLY#$%TRONGpa44w0rd;Encrypt=yes;TrustServerCertificate=no"

# Expose the port your app runs on
EXPOSE 5001

# Define the command to start the app
CMD ["flask", "run", "--host=0.0.0.0"]

# run container docker run --name python-web-api -d --restart always -p 5001:5000  python-web-api:1.0.0
