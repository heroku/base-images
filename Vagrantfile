Vagrant::Config.run do |config|
  config.vm.box = "lucid64"
  config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
  config.vm.network :hostonly, "33.33.33.3"
  config.ssh.forward_agent = true
  config.vm.share_folder("log", "/tmp/log", "tmp/log")

  config.vm.provision :shell, :inline => <<-'EOSRC'
(
  date

  apt-get update
  apt-get install -y curl git-core lxc s3cmd
  mkdir -p /cgroup
  mount none -t cgroup /cgroup

) 2>&1 | tee /tmp/log/provision.log
EOSRC
end