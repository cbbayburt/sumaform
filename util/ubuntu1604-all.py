#!/usr/bin/python
import xmlrpclib

manager_url = "http://localhost/rpc/api"
client = xmlrpclib.Server(manager_url, verbose=0)
key = client.auth.login('admin', 'admin')
cert = 'RHN-ORG-TRUSTED-SSL-CERT'


def clearChannels(channels):
    for label, props in sorted(channels.items(), key=lambda (k, v): v.get('parent', ''), reverse=True):
        try:
            client.channel.software.removeRepo(key, label)
            print('Deleted repo {}'.format(label))
        except xmlrpclib.Fault:
            pass  # if the repo does not exist

        try:
            client.channel.software.delete(key, label)
            print('Deleted channel {}'.format(props['name']))
        except xmlrpclib.Fault:
            pass  # if the channel does not exist


def addChannels(channels, cert, useSignedMetadata, archType):
    if archType == 'deb':
        channelArch = 'channel-amd64-deb'
    else:
        channelArch = 'channel-x86_64'

    for label, props in sorted(channels.items(), key=lambda (k, v): v.get('parent', '')):
        client.channel.software.createRepo(key, label, archType, props['url'], cert,
                                           cert, cert, useSignedMetadata)
        client.channel.software.create(key, label, props['name'],
                                              props.get('summary', props['name']),
                                              channelArch, props.get('parent', ''),
                                              'sha256')
        client.channel.software.associateRepo(key, label, label)
        print("Created channel '{}' with repository '{}'".format(props['name'], label))


def createActivationKey(channels, label, desc):
    parent = next((label for label, props in channels.items() if 'parent' not in props),
        channels.values()[0]['parent'])

    try:
        client.activationkey.delete(key, '1-' + label)
        print("Deleted activation key '{}'".format('1-' + label))
    except xmlrpclib.Fault:
        pass  # if the key does not exist

    activation_key = client.activationkey.create(key, label, desc, parent, [], False)

    children = [label for label, props in channels.items() if props.get('parent', '') == parent]
    children.append('ubuntu-16.04-suse-manager-tools-amd64')
    client.activationkey.addChildChannels(key, activation_key, children)
    print("Created activation key '{}'".format(activation_key))


def startRepoSync(channelLabels):
    client.channel.software.syncRepo(key, channelLabels)
    print("Started repo-sync for the created channels. Please check '/var/log/rhn/reposync.log' for the sync log.")

### Editable code

# Channel dict (only one parent supported)
channels = {
    'ubuntu-1604-amd64-backports-main': {
        'name': 'Ubuntu 16.04 LTS - Backports',
        'parent': 'ubuntu-16.04-pool-amd64',
        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-backports/main/binary-amd64'
    },
    'ubuntu-1604-amd64-backports-restricted': {
        'name': 'Ubuntu 16.04 LTS - Backports Restricted',
        'parent': 'ubuntu-16.04-pool-amd64',
        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-backports/restricted/binary-amd64'
    },
    'ubuntu-1604-amd64-main': {
        'name': 'Ubuntu 16.04 LTS',
        'parent': 'ubuntu-16.04-pool-amd64',
        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial/main/binary-amd64'
    },
    'ubuntu-1604-amd64-restricted': {
        'name': 'Ubuntu 16.04 LTS - Restricted',
        'parent': 'ubuntu-16.04-pool-amd64',
        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial/restricted/binary-amd64'
    },
    'ubuntu-1604-amd64-security-main': {
        'name': 'Ubuntu 16.04 LTS - Security',
        'parent': 'ubuntu-16.04-pool-amd64',
        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-security/main/binary-amd64'
    },
    'ubuntu-1604-amd64-security-restricted': {
        'name': 'Ubuntu 16.04 LTS - Security Restricted',
        'parent': 'ubuntu-16.04-pool-amd64',
        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-security/restricted/binary-amd64'
    },
    'ubuntu-1604-amd64-updates-main': {
        'name': 'Ubuntu 16.04 LTS - Updates',
        'parent': 'ubuntu-16.04-pool-amd64',
        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-updates/main/binary-amd64'
    },
    'ubuntu-1604-amd64-updates-restricted': {
        'name': 'Ubuntu 16.04 LTS - Updates Restricted',
        'parent': 'ubuntu-16.04-pool-amd64',
        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-updates/restricted/binary-amd64'
    }
#    'ubuntu-1604-amd64-backports-universe': {
#        'name': 'Ubuntu 16.04 LTS - Backports Universe',
#        'parent': 'ubuntu-16.04-pool-amd64',
#        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-backports/universe/binary-amd64'
#    },
#    'ubuntu-1604-amd64-universe': {
#        'name': 'Ubuntu 16.04 LTS - Universe',
#        'parent': 'ubuntu-16.04-pool-amd64',
#        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial/universe/binary-amd64'
#    },
#    'ubuntu-1604-amd64-security-universe': {
#        'name': 'Ubuntu 16.04 LTS - Security Universe',
#        'parent': 'ubuntu-16.04-pool-amd64',
#        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-security/universe/binary-amd64'
#    },
#    'ubuntu-1604-amd64-updates-universe': {
#        'name': 'Ubuntu 16.04 LTS - Updates Universe',
#        'parent': 'ubuntu-16.04-pool-amd64',
#        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-updates/universe/binary-amd64'
#    },
#    'ubuntu-1604-amd64-backports-multiverse': {
#        'name': 'Ubuntu 16.04 LTS - Backports Multiverse',
#        'parent': 'ubuntu-16.04-pool-amd64',
#        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-backports/multiverse/binary-amd64'
#    },
#    'ubuntu-1604-amd64-multiverse': {
#        'name': 'Ubuntu 16.04 LTS - Multiverse',
#        'parent': 'ubuntu-16.04-pool-amd64',
#        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial/multiverse/binary-amd64'
#    },
#    'ubuntu-1604-amd64-security-multiverse': {
#        'name': 'Ubuntu 16.04 LTS - Security Multiverse',
#        'parent': 'ubuntu-16.04-pool-amd64',
#        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-security/multiverse/binary-amd64'
#    },
#    'ubuntu-1604-amd64-updates-multiverse': {
#        'name': 'Ubuntu 16.04 LTS - Updates Multiverse',
#        'parent': 'ubuntu-16.04-pool-amd64',
#        'url': 'http://us.archive.ubuntu.com/ubuntu/dists/xenial-updates/multiverse/binary-amd64'
#    }
};

addChannels(channels, cert, False, 'deb')
createActivationKey(channels, 'UBUNTU-XENIAL-DEFAULT', 'Ubuntu 16.04 LTS')

startRepoSync(channels.keys())
### End editable code
