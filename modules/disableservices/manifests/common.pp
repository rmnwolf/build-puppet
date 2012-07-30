class disableservices::common {
# This class disables unnecessary services common to both server and slave
    
    case $operatingsystem {
        CentOS : {
            service {
                ['acpid', 'anacron', 'apmd', 'atd', 'auditd', 'autofs',
                'avahi-daemon', 'avahi-dnsconfd', 'bluetooth', 'cpuspeed',
                'cups', 'cups-config-daemon', 'gpm', 'hidd', 'hplip', 'kudzu',
                'mcstrans', 'mdmonitor', 'pcscd', 'restorecond', 'rpcgssd',
                'rpcidmapd', 'sendmail', 'smartd', 'vncserver',
                'yum-updatesd'] :
                    ensure => stopped,
            }
        }
        Darwin : {
            service {
                ['com.apple.blued'] :
                    enable => false,
                    ensure => stopped,
            }
            exec {
                "disable-indexing" :
                    command => "/usr/bin/mdutil -a -i off",
                    refreshonly => true ;

                "remove-index" :
                    command => "/usr/bin/mdutil -a -E",
                    refreshonly => true ;
                "disable-updater" :
                    command => "/usr/sbin/softwareupdate --schedule off",
                    unless =>
                    "/usr/sbin/softwareupdate --schedule off | egrep 'off'" ;
                "disable-wifi" :
                    command => "/usr/sbin/networksetup -setairportpower en1 off",
                    unless =>
                    "/usr/sbin/networksetup -getairportpower en1 | egrep 'off'" ;
            }
            file {
                "$settings::vardir/.puppet-indexing" :
                    content => "indexing-disabled",
                    notify => Exec["disable-indexing", "remove-index"] ;
            }
        }
    }
}
