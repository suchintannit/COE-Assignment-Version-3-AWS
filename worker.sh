echo "Step 1"
  sudo /vagrant/join.sh
  echo "This worker node joined the master"
  echo "created conf file for worker and reloaded system#####################"
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet