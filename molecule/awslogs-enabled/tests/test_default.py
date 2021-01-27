import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_chrony_sources(host):
    chrony_sources = host.check_output('chronyc -c sources')
    assert chrony_sources.startswith('^,*,169.254.169.123')
    assert chrony_sources.count('\n') == 0


def test_ssm_agent(host):
    assert host.service('amazon-ssm-agent').is_running
    assert host.service('amazon-ssm-agent').is_enabled


def test_nvme_mapping(host):
    assert host.service('nvme-mapping').is_enabled

    if host.system_info.distribution in ["centos"]:
        assert host.file('/dev/sda1').exists
        assert host.file('/dev/sda1').is_symlink
        assert host.file('/dev/sda1').linked_to == '/dev/nvme0n1'

    if host.system_info.distribution in ["debian"]:
        assert host.file('/dev/xvda').exists
        assert host.file('/dev/xvda').is_symlink
        assert host.file('/dev/xvda').linked_to == '/dev/nvme0n1'


def test_awslogs(host):
    assert host.service('awslogs').is_enabled

    assert host.file('/etc/awslogs').exists
    assert host.file('/etc/awslogs').is_symlink
    assert host.file('/etc/awslogs').linked_to == '/var/awslogs/etc'

    assert host.file('/var/awslogs/etc/awslogs.conf').exists
