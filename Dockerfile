# mssql-python-pyodbc
# Python runtime with pyodbc to connect to SQL Server
FROM python
MAINTAINER Marine Institute
# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gcc build-essential gcc-6-test-results\
    && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev

# install SQL Server tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# python libraries
#RUN apt-get update && apt-get install -y \
#    python-pip python-dev python-setuptools \
#    --no-install-recommends \
#    && rm -rf /var/lib/apt/lists/*

# install necessary locales
#RUN apt-get update && apt-get install -y locales \
#    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
#    && locale-gen
#RUN pip install --upgrade pip

# install SQL Server Python SQL Server connector module - pyodbc
RUN pip install pyodbc

# install additional utilities
#RUN apt-get update && apt-get install gettext nano vim -y

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY auth.py ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

RUN chmod +x getFromWormsVernSendToSQLServer.py
ENTRYPOINT ["python","./getFromWormsVernSendToSQLServer.py"]
CMD []
