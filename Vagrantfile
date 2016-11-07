Vagrant::Config.run do |config|
  config.vm.box = "trusty"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.network :hostonly, "33.33.33.3"
  config.ssh.forward_agent = true
  config.vm.share_folder("log", "/tmp/log", "tmp/log")

  config.vm.provision :shell, :inline => <<-'EOSRC'
(
  date

  apt-get update
  apt-get install -y curl git-core lxc python-pip
  pip install s3cmd
  mkdir -p /cgroup
  mount none -t cgroup /cgroup

) 2>&1 | tee /tmp/log/provision.log
EOSRC
end
