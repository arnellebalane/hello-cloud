set -v

# Install logging monitor. The monitor will automatically pick up logs sent to syslog.
curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
service google-fluentd restart &

# Install dependencies from apt
apt-get update
apt-get install -yq ca-certificates git build-essential supervisor

# Install nodejs
mkdir /opt/nodejs
curl https://nodejs.org/dist/v14.18.0/node-v14.18.0-linux-x64.tar.gz | tar xvzf - -C /opt/nodejs --strip-components=1
ln -s /opt/nodejs/bin/node /usr/bin/node
ln -s /opt/nodejs/bin/npm /usr/bin/npm

# Get the application source code from the GitHub repository.
# git requires $HOME and it's not set during the startup script.
export HOME=/root
git clone https://github.com/arnellebalane/hello-cloud /opt/app/hello-cloud

# Install app dependencies
cd /opt/app/hello-cloud/packages/backend
npm ci

# Create a nodeapp user. The application will run as this user.
useradd -m -d /home/nodeapp nodeapp
chown -R nodeapp:nodeapp /opt/app

# Set environment variables based on Google Secrets Manager
export CORS_ORIGINS=$(gcloud secrets versions access latest --secret CORS_ORIGINS)

# Create environment file that will be expanded inside the supervisor config
cat >/opt/app/hello-cloud/.env << EOF
HOME="/home/nodeapp",USER="nodeapp",NODE_ENV="production",CORS_ORIGINS="$CORS_ORIGINS"
EOF

# Create directory for storing application logs
mkdir /var/log/hello-cloud

# Configure supervisor to run the node app.
cat >/etc/supervisor/conf.d/hello-cloud.conf << EOF
[program:hello-cloud]
directory=/opt/app/hello-cloud/packages/backend
command=npm start
autostart=true
autorestart=true
user=nodeapp
environment=$(cat /opt/app/hello-cloud/.env)
stdout_logfile=/var/log/hello-cloud/stdout.log
stderr_logfile=/var/log/hello-cloud/stderr.log
EOF

supervisorctl reread
supervisorctl update

# Application should now be running under supervisor
