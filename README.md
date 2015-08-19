# composed
Composed devops test

This VagrantFile deploys a standard ubuntu vm then calls the script deploy.sh using the shell provisioner.

Deploy.sh deploys ruby on rails in an idempotent manner so should be safe to run repeatedly.

Idempotence was achieved wherever possible using version number checks against version numbers defined in variables at the top for the script. This should make the script safe to run repeatedly, as new releases of upstream packages won't force an upgrade intil we're ready.

git clone https://github.com/stephenjirvine/composed.git

cd composed

vagrant up
